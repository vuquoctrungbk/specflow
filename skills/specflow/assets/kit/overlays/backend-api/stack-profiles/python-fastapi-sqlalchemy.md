---
doc_type: profile
status: stable
version: 1.0.1
language: en
surface: backend-api
profile: python-fastapi-sqlalchemy
---

# Stack profile python-fastapi-sqlalchemy

## 1. Scope

Backend API written in Python on CPython 3.13, FastAPI framework on ASGI, SQLAlchemy 2 ORM in async mode with the `psycopg` 3 driver, Alembic migrations, PostgreSQL database, dependencies and environment managed with `uv`. The profile matches a project created with `uv init --package` plus the libraries in §2.

The versions were pinned on 2026-09-23 and run together on a trial project: OpenAPI document export, lint and format for `migrations/` as well, strict typecheck, unit, integration on an isolated PostgreSQL, e2e, contract, rate limiting, `CONC`, coverage, wheel build, audit, `alembic check` and OpenAPI lint all exit 0. `{{MIGRATION_DEPLOY_CMD}}` ran on its own against an empty database, including with a password that has percent-encoded characters and an environment that holds only the connection variable.

Not verified in the trial project; a project that uses the profile has to confirm them itself: running the application with `uvicorn` behind a reverse proxy, rate limiting with shared storage when there are several instances, foreign keys, `UniqueConstraint` and `Numeric` columns. Upgrade versions under the Dependency Policy in ARCHITECTURE §2.2.

Choose this profile when the project already has a Python ecosystem (machine learning models, data processing libraries, a team that writes Python). A new project with no language constraint compares it with the `node-nestjs-prisma` profile of the same overlay and records the choice in an ADR.

## 2. Technology Table (Tech Stack)

Copy into ARCHITECTURE §2.1 with the Surface column set to `backend-api` and the ADR column set to "Profile default" (only a deviation from the profile needs an ADR).

| Layer | Technology | Exact version | Role | ADR |
| --- | --- | --- | --- | --- |
| Runtime | CPython | 3.13.13 | Runs the application and tools; pinned by `.python-version` | Profile default |
| Project manager | `uv` | 0.12.18 | Locks dependencies, virtual environment, runs commands, builds the wheel | Profile default |
| Build backend | `uv_build` | 0.12.18 | Wheel build backend, declared in `[build-system]` | Profile default |
| Framework | `fastapi` | 0.141.1 | Router, dependency injection, OpenAPI 3.1 generation | Profile default |
| ASGI server | `uvicorn[standard]` | 0.53.0 | Runs the application, uses `uvloop` and `httptools` | Profile default |
| Validation | `pydantic` | 2.13.5 | Request and response DTOs, field constraints | Profile default |
| Configuration | `pydantic-settings` | 2.15.0 | Reads and validates environment variables in a single place | Profile default |
| ORM | `sqlalchemy[asyncio]` | 2.0.54 | Typed mapping (`Mapped`, `mapped_column`), queries, transactions | Profile default |
| Migration | `alembic` | 1.20.0 | Generates and runs migrations, `alembic check` compares the schema with the metadata | Profile default |
| Driver | `psycopg[binary,pool]` | 3.3.6 | Async PostgreSQL driver, connection pool | Profile default |
| Database | PostgreSQL | 18.6 | Relational storage, ACID transactions | Profile default |
| Logging | `structlog` | 26.1.0 | One-line JSON logs, attaches the correlation ID from context | Profile default |
| Authentication | `pyjwt` | 2.14.0 | Signs and verifies access tokens | Profile default |
| Password hashing | `argon2-cffi` | 25.1.0 | Argon2id | Profile default |
| Rate limiting | `limits` | 5.8.0 | Sliding window, in-process storage or Redis when there are several instances | Profile default |
| Test | `pytest` | 9.1.1 | Runs tests | Profile default |
| Test | `pytest-asyncio` | 1.4.0 | Async tests, `auto` mode | Profile default |
| Test | `pytest-cov` | 7.1.0 | Line and branch coverage | Profile default |
| Test | `httpx` | 0.28.1 | E2E client that calls the application through `ASGITransport`, without opening a port | Profile default |
| Test | `testcontainers[postgres]` | 4.15.0 | Isolated PostgreSQL for integration, e2e, `CONC` | Profile default |
| Test | `jsonschema`, `types-jsonschema` | 4.26.0, 4.26.0.20260518 | `CTR` tests compare responses with the schema in the OpenAPI document | Profile default |
| Lint and format | `ruff` | 0.16.8 | Lint and format, replaces the flake8 plus black set | Profile default |
| Typecheck | `mypy` | 2.3.1 | Type checking in `strict` mode | Profile default |
| Audit | `pip-audit` | 2.10.1 | Compares locked dependencies with the vulnerability database | Profile default |
| API documentation | `openapi-spec-validator` | 0.9.0 | Checks `openapi/openapi.yaml` against OpenAPI 3.1, no Node.js needed | Profile default |
| API documentation | `pyyaml`, `types-pyyaml` | 6.0.3, 6.0.12.20260906 | Writes and reads the OpenAPI document as YAML; type stubs for mypy | Profile default |

## 3. Placeholder values

| Placeholder | Value |
| --- | --- |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | `mypy` runs `strict` for `src/` and `tests/`; `ruff` enables the `ANN` group so every function must have annotations and `Any` in an annotation is blocked; `Any` is used only at the JSON serialization boundary. |
| `{{ISOLATION_LEVEL}}` | `READ COMMITTED` |
| `{{CODEGEN_CMD}}` | `uv run python -m app.openapi_export` |
| `{{LINT_CMD}}` | `uv run ruff check src tests migrations && uv run ruff format --check src tests migrations` |
| `{{TYPECHECK_CMD}}` | `uv run mypy` |
| `{{UNIT_TEST_CMD}}` | `uv run pytest tests/unit` |
| `{{INTEGRATION_TEST_CMD}}` | `uv run pytest tests/integration` |
| `{{E2E_TEST_CMD}}` | `uv run pytest tests/e2e tests/concurrency` |
| `{{COVERAGE_CMD}}` | `uv run pytest tests --cov --cov-fail-under=80` |
| `{{BUILD_CMD}}` | `uv build --wheel` |
| `{{AUDIT_CMD}}` | `uv run pip-audit --strict` |
| `{{MIGRATION_CHECK_CMD}}` | `uv run alembic check` |
| `{{MIGRATION_DEPLOY_CMD}}` | `uv run alembic upgrade head` |
| `{{OPENAPI_LINT_CMD}}` | `uv run openapi-spec-validator openapi/openapi.yaml` |

Notes:

- FastAPI generates the OpenAPI document from code, so `{{CODEGEN_CMD}}` is the step that exports that document to `openapi/openapi.yaml`, not one that generates code. The command runs before every other command and runs again after each router or DTO change; the resulting file is committed so review can diff it and so the `CTR` tests can compare against it.
- The two migration commands need only the `DATABASE_URL` variable, no other application variable, so the migration job at release time does not have to carry the application secrets.
- `{{MIGRATION_CHECK_CMD}}` needs a running database that is already at `upgrade head`: `alembic check` compares the ORM metadata with the real schema and returns non-zero when a change has no migration yet. In CI, run it against the job's disposable database.
- `uv run` syncs the environment with `uv.lock` before it runs, so no separate install step is needed; CI uses `uv sync --frozen` so it fails when the lock does not match `pyproject.toml`.
- `pip-audit` reads the locked environment; `--strict` turns warnings into errors. A vulnerability without a patch gets an ADR accepting the risk and `--ignore-vuln <id>` with a review date.
- The profile's default coverage threshold is 80% of lines and branches for `src/app/`, measured by the `[tool.coverage.run]` configuration; the SRS may set another threshold in NFR-MAINT.
- Tests use `testcontainers`, so the machine that runs the tests needs Docker. An environment without Docker sets a variable that points to a disposable PostgreSQL and records the method in ARCHITECTURE §11.
- Run the application during development: `uv run uvicorn --factory app.main:create_app --port 8000`; behind a reverse proxy add `--proxy-headers --forwarded-allow-ips <proxy IP>` so the client address in the logs and in the rate limit counter is the real address.

## 4. Profile Content

### 4.1. Directory tree and tool configuration (for ARCHITECTURE §4)

<!-- PROFILE-CONTENT: arch.layout -->
### Stack Directory Tree

```text
.
├── pyproject.toml                       # dependencies, ruff, mypy, pytest, coverage, build configuration
├── uv.lock                              # locks the whole dependency tree, committed to the repo
├── .python-version                      # exact CPython version, uv reads this file
├── .env.example                         # names of all environment variables with sample values, no real values
├── alembic.ini                          # Alembic configuration, script_location and prepend_sys_path
├── openapi/openapi.yaml                 # OpenAPI 3.1 document exported from the application, committed to the repo
├── migrations/
│   ├── env.py                           # loads the ORM metadata, runs migrations on the async engine
│   ├── script.py.mako                   # migration file template, adjusted for ruff and modern types
│   └── versions/                        # generated migrations, not edited once run in another environment
├── src/app/
│   ├── main.py                          # create_app: middleware, exception handlers, routers, lifespan, openapi
│   ├── config.py                        # the only place that reads environment variables, and the settings dependency
│   ├── openapi_export.py                # writes the OpenAPI document to openapi/openapi.yaml
│   ├── db/
│   │   ├── base.py                      # DeclarativeBase and constraint naming convention
│   │   └── session.py                   # engine, session factory, one session per request dependency
│   ├── lib/
│   │   ├── envelope.py                  # success envelope per ARCHITECTURE §6.2
│   │   ├── errors.py                    # Registry error codes, HTTP status mapping, error envelope
│   │   ├── logging.py                   # structlog configuration and correlation ID middleware
│   │   ├── security.py                  # password hashing, token signing and reading, bearer scheme for OpenAPI
│   │   └── rate_limit.py                # rate limit dependency and RateLimit-* headers
│   └── modules/{{MODULE_SLUG}}/
│       ├── router.py                    # APIRouter, endpoint declarations, response codes and response models
│       ├── schemas.py                   # request and response DTOs in Pydantic
│       ├── service.py                   # business rules, transaction boundary, idempotency
│       ├── repository.py                # SQLAlchemy queries, no business rules
│       └── model.py                     # tables of the module, typed mapping
└── tests/
    ├── conftest.py                      # PostgreSQL container fixture, session, client, table cleanup
    ├── unit/                            # pure functions, no database access
    ├── integration/                     # service and repository on a real database
    ├── e2e/                             # calls the application through httpx ASGITransport, includes CTR tests
    └── concurrency/                     # CONC tests, many parallel requests against one invariant
```

For this stack `{{MODULE_SLUG}}` is written in plural `snake_case`, because the directory name is also the Python package name and a hyphen is not valid.

Tool configuration lives in the same `pyproject.toml` file:

```toml
[tool.ruff]
line-length = 120
src = ["src", "tests"]
target-version = "py313"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "S", "ASYNC", "ANN", "RUF"]

[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101"]
"migrations/versions/**" = ["ANN"]  # generated migration bodies carry no annotations

[tool.mypy]
python_version = "3.13"
strict = true
mypy_path = "src"
packages = ["app", "tests"]
exclude = ["migrations/versions/"]
plugins = []

[[tool.mypy.overrides]]
module = ["testcontainers.*"]
ignore_missing_imports = true

[tool.pytest.ini_options]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "session"
testpaths = ["tests"]
pythonpath = ["src"]
addopts = "-q"

[tool.coverage.run]
source = ["src/app"]
branch = true

[tool.coverage.report]
skip_empty = true
```
Default Diff files when a SPEC adds a write endpoint: `router.py`, `schemas.py`, `service.py`, `repository.py`, `model.py` of the module, one file in `migrations/versions/`, `openapi/openapi.yaml`, and the tests of each kind in `tests/`.
<!-- /PROFILE-CONTENT -->

### 4.2. SQLAlchemy schema and Alembic (for ARCHITECTURE §5)

<!-- PROFILE-CONTENT: arch.schema -->
### SQLAlchemy Schema Conventions

The base class declares the naming convention, so migrations name constraints the same way in every environment and `alembic check` can compare them:

```python
from sqlalchemy import MetaData
from sqlalchemy.orm import DeclarativeBase

# Named constraints so migrations can drop and recreate them by name on every database.
NAMING_CONVENTION = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}


class Base(DeclarativeBase):
    metadata = MetaData(naming_convention=NAMING_CONVENTION)
```
| Concept | SQLAlchemy form |
| --- | --- |
| Class and table name | Singular `PascalCase` class for `{{ENTITY_NAME}}`, `__tablename__` in plural `snake_case` |
| Column | `title: Mapped[str] = mapped_column(String(200))`; the Python type decides `nullable`, so `Mapped[str | None]` means the column allows null |
| UUID primary key | `mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)` |
| String | `String(n)` with `n` matching the constraint in the DTO; `Text()` only when the DTO has no length limit either |
| Currency | `Numeric(12, 2)`, read out as `decimal.Decimal`, never `float` |
| Time | `DateTime(timezone=True)` with `server_default=func.now()`; a last-modified column adds `onupdate=func.now()` |
| Enum | `String(n)` plus a `CheckConstraint` listing the `UPPER_SNAKE` values, matching SRS §4.2; the PostgreSQL `ENUM` type needs an ADR because changing a value requires a migration |
| Check constraint | `__table_args__ = (CheckConstraint("...", name="..."),)`, short name because the naming convention adds the table prefix |
| Foreign key | `mapped_column(ForeignKey("parents.id", ondelete="RESTRICT"), index=True)`, the parent table name in plural like its `__tablename__` |
| Composite unique | `UniqueConstraint("a", "b")` in `__table_args__` |
| JSON | `JSONB()` from the PostgreSQL dialect, the Python type is `dict[str, Any]` |

`migrations/env.py` reads only the connection variable and creates the engine straight from that value. Do not push the URL through `config.set_main_option`: configparser interpolates the `%` character, so a percent-encoded password kills the migration command with `ValueError: invalid interpolation syntax`. Loading the application's whole `Settings` class is not allowed either, because then the migration job at release time would have to carry every application secret.

```python
import asyncio
import os
from logging.config import fileConfig

from alembic import context
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import create_async_engine

from app.db.base import Base
from app.modules.records import model  # noqa: F401  (imported so its tables are in the metadata)

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# The migration job reads one variable, not the whole application configuration, so it runs in a release step that
# has no application secrets. The URL never passes through config.set_main_option, whose interpolation would break
# on a password with a percent sign.
DATABASE_URL = os.environ["DATABASE_URL"]
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    context.configure(url=DATABASE_URL, target_metadata=target_metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata, compare_type=True)
    with context.begin_transaction():
        context.run_migrations()


async def run_migrations_online() -> None:
    connectable = create_async_engine(DATABASE_URL, poolclass=pool.NullPool)
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()


if context.is_offline_mode():
    run_migrations_offline()
else:
    asyncio.run(run_migrations_online())
```
Remaining rules:

- `migrations/env.py` imports `Base` and every `model` module so the metadata holds all tables.
- `alembic revision --autogenerate` is only a draft: reread the generated file, add the missing indexes and the SQL for data, and only then commit.
- `compare_type=True` in `context.configure` so a column type change is not missed; this is what lets `{{MIGRATION_CHECK_CMD}}` catch a change in string length.
- A migration that has run in another environment is not edited; write a new migration.
<!-- /PROFILE-CONTENT -->

### 4.3. Communication conventions of the stack (for ARCHITECTURE §7)

<!-- PROFILE-CONTENT: arch.conventions -->
### Stack Implementation Notes

- `create_app(settings)` in `src/app/main.py` is the only place that builds the application: it attaches the correlation ID middleware, registers exception handlers for business errors and validation errors, includes the router of each module, opens the engine in `lifespan` and calls `dispose` on shutdown, and overrides `app.openapi()` so the exported document matches the contract. Tests build the application with this same function and their own `Settings`.
- Configuration is read once with `pydantic-settings`; dependencies read it back from `app.state`, never read environment variables in a route, so tests can inject configuration:

  ```python
  from functools import lru_cache
  from typing import Annotated, Literal

  from fastapi import Depends, Request
  from pydantic import AnyHttpUrl, Field, PostgresDsn
  from pydantic_settings import BaseSettings, SettingsConfigDict


  class Settings(BaseSettings):
      """The only place that reads environment variables; secrets stay in memory."""

      model_config = SettingsConfigDict(env_file=None, extra="forbid")

      app_env: Literal["local", "test", "staging", "production"] = "local"
      database_url: PostgresDsn
      public_base_url: AnyHttpUrl = AnyHttpUrl("http://127.0.0.1:8000")
      jwt_secret: str = Field(min_length=32)
      jwt_ttl_seconds: int = Field(default=900, ge=60, le=3600)
      rate_limit_per_minute: int = Field(default=60, ge=1)
      log_level: Literal["debug", "info", "warning", "error"] = "info"


  @lru_cache(maxsize=1)
  def get_settings() -> Settings:
      return Settings()  # type: ignore[call-arg]


  def settings_of(request: Request) -> Settings:
      """Dependencies read the settings the app was created with, never the environment, so tests can inject them."""
      settings: Settings = request.app.state.settings
      return settings


  SettingsDep = Annotated[Settings, Depends(settings_of)]
  ```
- One session per request, taken from the session factory held in `app.state`; the isolation level is set on the engine:

  ```python
  from collections.abc import AsyncIterator
  from typing import Annotated

  from fastapi import Depends, Request
  from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker, create_async_engine

  from app.config import Settings


  def create_engine(settings: Settings) -> AsyncEngine:
      """One pool per process; READ COMMITTED is the isolation level every transaction of this stack runs at."""
      return create_async_engine(
          str(settings.database_url),
          pool_size=10,
          max_overflow=5,
          pool_pre_ping=True,
          isolation_level="READ COMMITTED",
      )


  def create_session_factory(engine: AsyncEngine) -> async_sessionmaker[AsyncSession]:
      return async_sessionmaker(engine, expire_on_commit=False, autoflush=False)


  async def get_session(request: Request) -> AsyncIterator[AsyncSession]:
      """One session per request; the route handler owns the transaction boundary."""
      factory: async_sessionmaker[AsyncSession] = request.app.state.session_factory
      async with factory() as session:
          yield session


  SessionDep = Annotated[AsyncSession, Depends(get_session)]
  ```
- The transaction boundary is in the service: the reads and writes of one operation run in the implicit transaction the session has already opened, and the service calls `await session.commit()` exactly once at the end. Do not call `session.begin()` after the session already ran a query, because SQLAlchemy opened a transaction at that query and the second call raises `InvalidRequestError`.
- Idempotency for write operations: one table holds the key, the body fingerprint and the response already returned. A resend with the same key reads back the old response; the same key with a different body returns the Registry error code. When two parallel requests carry the same key, the table's primary key makes the losing request receive an `IntegrityError`; the service catches that error, rolls back and reads back the response of the winning request.
- Every successful response is wrapped in the envelope of ARCHITECTURE §6.2; a route declares its return type as `Envelope[...]` so the OpenAPI document carries this exact shape:

  ```python
  import datetime as dt

  from pydantic import BaseModel, ConfigDict, Field


  class Meta(BaseModel):
    """Paging and counters that belong next to the data, never inside it."""

    model_config = ConfigDict(populate_by_name=True)

    next_cursor: str | None = Field(default=None, serialization_alias="nextCursor")
    total: int | None = None


  class Envelope[T](BaseModel):
    """The shape of every successful answer (ARCHITECTURE section 6.2)."""

    success: bool = True
    data: T
    meta: Meta | None = None
    timestamp: dt.datetime = Field(default_factory=lambda: dt.datetime.now(tz=dt.UTC))


  def ok[T](data: T, meta: Meta | None = None) -> Envelope[T]:
    return Envelope[T](data=data, meta=meta)
  ```
- <!-- fill: list exactly the error codes of the Error Code Registry in ARCHITECTURE §7.1; the table below is a sample --> Error codes are declared in one place together with the HTTP status, and a business error is an exception that carries that code; the error envelope has `timestamp` and `details` as a list of `{field, issue}`:

  ```python
  import datetime as dt
  from dataclasses import dataclass, field
  from typing import Any

  # Every error code the API answers with is declared here once, with the HTTP status it maps to.
  ERROR_STATUS: dict[str, int] = {
      "VALIDATION_ERROR": 400,
      "UNAUTHENTICATED": 401,
      "FORBIDDEN": 403,
      "RECORD_NOT_FOUND": 404,
      "IDEMPOTENCY_KEY_REUSED": 409,
      "VERSION_CONFLICT": 409,
      "RATE_LIMITED": 429,
      "INTERNAL_ERROR": 500,
  }


  @dataclass(frozen=True, slots=True)
  class AppError(Exception):
      """A failure the API answers with a declared error code."""

      code: str
      message: str
      details: list[dict[str, str]] | None = None
      headers: dict[str, str] = field(default_factory=dict)

      @property
      def status_code(self) -> int:
          return ERROR_STATUS.get(self.code, 500)


  def error_body(
      code: str, message: str, correlation_id: str, details: list[dict[str, str]] | None = None
  ) -> dict[str, Any]:
      """The error envelope of ARCHITECTURE section 6.2: details is a list of {field, issue}."""
      error: dict[str, Any] = {
          "code": code,
          "message": message,
          "correlationId": correlation_id,
          "timestamp": dt.datetime.now(tz=dt.UTC).isoformat(),
      }
      if details is not None:
          error["details"] = details
      return {"success": False, "error": error}
  ```
- The `AppError` handler returns the error envelope with the `correlationId` and the headers the error carries; the `RequestValidationError` handler returns the code `VALIDATION_ERROR` with the list of invalid fields, so FastAPI validation errors do not leak out as the default `422`.
- `app.openapi()` is overridden to remove the `422` response FastAPI adds by itself, keeping the document aligned with the error matrix of the SPEC. `FastAPI(...)` declares `servers`, `license_info`, and shared `responses` for the error codes any route can return, and `generate_unique_id_function` generates `operationId` in `camelCase`.
- Logs are one-line JSON from `structlog`; the middleware takes the caller's `X-Correlation-Id` or generates a new one, attaches it to the context and returns it in the response header. Never log tokens, passwords or personal data.
- Rate limiting is a dependency that counts per authenticated subject; every response carries the three headers `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`, and a rejection adds `Retry-After` computed from the current window:

  ```python
  import datetime as dt

  from fastapi import Response
  from limits import RateLimitItemPerMinute
  from limits.aio.storage import MemoryStorage
  from limits.aio.strategies import MovingWindowRateLimiter

  from app.config import SettingsDep
  from app.lib.errors import AppError
  from app.lib.security import CurrentSubject

  # In-process counters: one instance, one window. A deployment with more than one instance passes a shared storage
  # here (limits ships Redis and Memcached backends), otherwise every instance grants the full quota.
  _storage = MemoryStorage()
  _limiter = MovingWindowRateLimiter(_storage)


  def _headers(limit: int, remaining: int, reset_seconds: int) -> dict[str, str]:
      return {
          "RateLimit-Limit": str(limit),
          "RateLimit-Remaining": str(max(remaining, 0)),
          "RateLimit-Reset": str(max(reset_seconds, 0)),
      }


  async def enforce_rate_limit(subject: CurrentSubject, settings: SettingsDep, response: Response) -> None:
      """Counts per authenticated subject, not per connection, so one caller cannot spread its load over addresses."""
      item = RateLimitItemPerMinute(settings.rate_limit_per_minute)
      allowed = await _limiter.hit(item, subject)
      window = await _limiter.get_window_stats(item, subject)
      reset_seconds = int(window.reset_time - dt.datetime.now(tz=dt.UTC).timestamp())
      headers = _headers(settings.rate_limit_per_minute, window.remaining, reset_seconds)
      if not allowed:
          raise AppError(
              "RATE_LIMITED",
              "Too many requests for this caller",
              [{"field": "subject", "issue": f"retry after {max(reset_seconds, 1)} seconds"}],
              {**headers, "Retry-After": str(max(reset_seconds, 1))},
          )
      response.headers.update(headers)


  async def reset_rate_limits() -> None:
      await _storage.reset()
  ```
  A public (unauthenticated) route counts per real client address: run `uvicorn` with `--proxy-headers --forwarded-allow-ips` of the trusted proxy, then take `request.client.host`. With several instances, replace `MemoryStorage` with shared storage from `limits`, otherwise each instance grants the full quota.
- Authentication uses `pyjwt` with the `HS256` algorithm and a short lifetime; passwords are hashed with Argon2id from `argon2-cffi`. The `HTTPBearer(auto_error=False)` scheme both generates `securitySchemes` in the OpenAPI document and turns a missing header into the project's `UNAUTHENTICATED` envelope instead of FastAPI's default error body.
<!-- /PROFILE-CONTENT -->

### 4.4. DTO template (for SPEC §3)

<!-- PROFILE-CONTENT: spec.contract -->
### Pydantic DTO Schema

<!-- fill: replace field names and constraints with the DTO of the feature; the block below is a sample -->

```python
import datetime as dt
import uuid
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, StringConstraints

Title = Annotated[str, StringConstraints(min_length=1, max_length=200, strip_whitespace=True)]
Note = Annotated[str, StringConstraints(max_length=2000)]


class CreateRecordRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    title: Title
    note: Note | None = None


class RecordResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

    id: uuid.UUID
    title: str
    note: str | None
    status: Literal["DRAFT", "ACTIVE", "ARCHIVED"]
    version: int
    created_at: dt.datetime = Field(serialization_alias="createdAt")
    updated_at: dt.datetime = Field(serialization_alias="updatedAt")
```
- `extra="forbid"` on requests so an unknown field is rejected instead of ignored.
- Field names in Python are `snake_case`; the outgoing JSON uses `camelCase` through `serialization_alias`, matching the envelope convention in ARCHITECTURE §6.2.
- `from_attributes=True` on responses to build straight from ORM objects.
- Length and value-domain constraints are written right in the type (`StringConstraints`, `Literal`, `Field(ge=..., le=...)`), so the generated OpenAPI document carries the exact constraints of the SPEC.
- A route declares the return type `Envelope[{{ENTITY_NAME}}Response]` and its own error codes in `responses`; the OpenAPI fragment of the SPEC (a companion file of the SPEC) is a cut from the exported `openapi/openapi.yaml`, not written by hand.
<!-- /PROFILE-CONTENT -->

### 4.5. Test tooling (for SPEC §9)

<!-- PROFILE-CONTENT: spec.test-types -->
### Stack Test Tooling

| TYPE | Tool | File | Run with |
| --- | --- | --- | --- |
| `UNIT` | pytest, pure functions and classes that do not touch the database | `tests/unit/test_*.py` | `{{UNIT_TEST_CMD}}` |
| `INT` | pytest, `testcontainers[postgres]`, a real SQLAlchemy session | `tests/integration/test_*.py` | `{{INTEGRATION_TEST_CMD}}` |
| `E2E` | pytest, `httpx.AsyncClient` with `ASGITransport`, application built by `create_app` | `tests/e2e/test_*.py` | `{{E2E_TEST_CMD}}` |
| `CTR` | Like `E2E`, takes the response schema from the exported `openapi/openapi.yaml` and checks with `jsonschema` | `tests/e2e/test_contract.py` | `{{E2E_TEST_CMD}}` |
| `CONC` | pytest, `asyncio.gather` sends N parallel requests, then queries to assert the invariant | `tests/concurrency/test_*.py` | `{{E2E_TEST_CMD}}` |
| `LOAD` | Tool chosen by ADR when the SPEC needs it | Outside `tests/` | Not part of pytest |

Shared fixtures live in `tests/conftest.py`: one PostgreSQL container for the whole test session, the `Settings` of the test environment, a session factory with the tables created, one session per test, an `httpx` client that carries a token, and an autouse fixture that wipes the tables after each test.

```python
from collections.abc import AsyncIterator, Iterator

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker
from testcontainers.community.postgres import PostgresContainer

from app.config import Settings
from app.lib.security import create_access_token
from app.main import create_app

@pytest.fixture(scope="session")
def postgres_url() -> Iterator[str]:
    """One disposable PostgreSQL per test session; nothing touches a database of the developer."""
    with PostgresContainer("postgres:18.6-alpine", driver="psycopg") as container:
        yield container.get_connection_url()


@pytest.fixture
async def client(settings: Settings, session_factory: async_sessionmaker[AsyncSession]) -> AsyncIterator[AsyncClient]:
    app = create_app(settings)
    app.state.session_factory = session_factory
    transport = ASGITransport(app=app)
    token = create_access_token(OWNER, settings)
    async with AsyncClient(
        transport=transport, base_url="http://api.test", headers={"Authorization": f"Bearer {token}"}
    ) as opened:
        yield opened
```
`asyncio_mode = "auto"` so async tests need no decorator. Test names describe behavior in English, for example `def test_a_request_without_a_token_is_refused(...)`; they do not contain a TC ID.
<!-- /PROFILE-CONTENT -->

## 5. Stack Conventions

- `src/` layout: code lives in `src/app/`, declared in `[tool.uv.build-backend]` with `module-name = "app"` and `module-root = "src"`; the pytest `pythonpath = ["src"]` lets tests import straight from the source tree.
- `uv.lock` and `.python-version` are committed to the repo; CI runs `uv sync --frozen` to detect a stale lock.
- The module directory name is plural `snake_case` because it is also the Python package name; this exception for `{{MODULE_SLUG}}` is recorded in ARCHITECTURE §4 when it is assembled.
- Lint and format run for `migrations/` as well; only the body of files in `migrations/versions/` is exempt from the `ANN` group, because the Alembic template generates bodies without annotations, and `mypy` skips exactly that directory.
- Every async function that touches the network or the database has a return annotation; the `ruff` `ASYNC` group catches calls that block the event loop, for example reading a file with `pathlib` in an async function.
- The `ruff` `S` group (bandit) is enabled for `src/`; `tests/` ignores `S101` because tests use `assert`.
- Do not use `print`; every record goes through the `structlog` logger.
- `mypy` in `strict` mode needs `# type: ignore[call-arg]` when instantiating `Settings` with no arguments (every value comes from the environment) and `# type: ignore[arg-type]` when passing a string into a `PostgresDsn` field in a test; keep exactly those two places, do not loosen `strict`.

## 6. Project Setup

1. Install `uv` 0.12.18, then `uv python install 3.13` and `uv python pin 3.13.13` to pin the exact runtime of the profile.
2. `uv init --package <name>` then adjust the project to match the tree in §4.1: rename `src/<name>` to `src/app`, add `[tool.uv.build-backend]` with `module-name = "app"` and `module-root = "src"`, remove the `[project.scripts]` block the scaffold generates, set `requires-python = "==3.13.*"`.
3. Add dependencies with the exact versions in §2, for example `uv add "fastapi==0.141.1" "sqlalchemy[asyncio]==2.0.54" "psycopg[binary,pool]==3.3.6" "alembic==1.20.0" "pydantic-settings==2.15.0"`, and the dev group with `uv add --dev "pytest==9.1.1" "ruff==0.16.8" "mypy==2.3.1"`.
4. Copy the configuration blocks in §4.1 into `pyproject.toml`, and create `.env.example` listing every environment variable with sample values.
5. `uv run alembic init -t async migrations`, then edit: in `alembic.ini` set `prepend_sys_path = src`, `script_location = migrations`, `timezone = UTC`; keep `%%` in `file_template` (configparser interpolates) but keep a single `%` in `[formatter_generic] format`, because doubling it there makes the log print the format string itself; rewrite `migrations/env.py` per §4.2; in `migrations/script.py.mako` change `from typing import Sequence` to `from collections.abc import Sequence` and `Union[str, None]` to `str | None` so the generated file passes `ruff`.
6. Create `src/app/` per the tree in §4.1, write `create_app`, configuration, session, envelope, errors, logging, security, rate limiting before writing the first module.
7. Run `{{CODEGEN_CMD}}` and then the remaining verify commands in turn to confirm the environment is complete (Docker for `testcontainers`, PostgreSQL and the `DATABASE_URL` variable for the two migration commands).
