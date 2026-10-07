---
doc_type: profile
status: stable
version: 1.0.1
language: vi-en
surface: backend-api
profile: python-fastapi-sqlalchemy
---

# Stack profile python-fastapi-sqlalchemy

## 1. Phạm vi (Scope)

Backend API viết bằng Python chạy trên CPython 3.13, framework FastAPI trên ASGI, ORM SQLAlchemy 2 ở chế độ async với driver `psycopg` 3, migration bằng Alembic, cơ sở dữ liệu PostgreSQL, quản lý dependency và môi trường bằng `uv`. Profile khớp dự án khởi tạo bằng `uv init --package` cộng các thư viện ở mục 2.

Phiên bản chốt ngày 2026-09-23 và đã chạy thử cùng nhau trên một dự án thử: xuất tài liệu OpenAPI, lint và định dạng cho cả `migrations/`, typecheck nghiêm ngặt, unit, integration trên PostgreSQL chạy cô lập, e2e, contract, giới hạn tần suất, `CONC`, coverage, build wheel, audit, `alembic check` và lint OpenAPI đều exit 0. `{{MIGRATION_DEPLOY_CMD}}` chạy riêng trên một cơ sở dữ liệu rỗng, kể cả với mật khẩu có ký tự percent-encode và môi trường chỉ có biến kết nối.

Chưa kiểm chứng trong dự án thử, dự án dùng profile phải tự xác nhận: chạy ứng dụng bằng `uvicorn` sau reverse proxy, giới hạn tần suất với storage dùng chung khi có nhiều instance, khóa ngoại, `UniqueConstraint` và cột `Numeric`. Nâng phiên bản theo Dependency Policy ở ARCHITECTURE §2.2.

Chọn profile này khi dự án đã có hệ sinh thái Python (mô hình học máy, thư viện xử lý dữ liệu, đội ngũ viết Python). Dự án mới không ràng buộc ngôn ngữ thì so sánh với profile `node-nestjs-prisma` của cùng overlay và ghi lựa chọn vào ADR.

## 2. Bảng công nghệ (Tech Stack)

Chép vào ARCHITECTURE §2.1 với cột Bề mặt là `backend-api` và cột ADR là "Mặc định của profile" (chỉ lệch profile mới cần ADR).

| Lớp (Layer) | Công nghệ | Phiên bản chính xác | Vai trò | ADR |
| --- | --- | --- | --- | --- |
| Runtime | CPython | 3.13.13 | Chạy ứng dụng và công cụ; ghim bằng `.python-version` | Mặc định của profile |
| Quản lý dự án | `uv` | 0.12.18 | Khóa dependency, môi trường ảo, chạy lệnh, build wheel | Mặc định của profile |
| Build backend | `uv_build` | 0.12.18 | Backend build wheel, khai báo ở `[build-system]` | Mặc định của profile |
| Framework | `fastapi` | 0.141.1 | Router, dependency injection, sinh OpenAPI 3.1 | Mặc định của profile |
| Máy chủ ASGI | `uvicorn[standard]` | 0.53.0 | Chạy ứng dụng, dùng `uvloop` và `httptools` | Mặc định của profile |
| Validation | `pydantic` | 2.13.5 | DTO request và response, ràng buộc trường | Mặc định của profile |
| Cấu hình | `pydantic-settings` | 2.15.0 | Đọc và kiểm tra biến môi trường ở một nơi duy nhất | Mặc định của profile |
| ORM | `sqlalchemy[asyncio]` | 2.0.54 | Mapping có kiểu (`Mapped`, `mapped_column`), truy vấn, transaction | Mặc định của profile |
| Migration | `alembic` | 1.20.0 | Sinh và chạy migration, `alembic check` so schema với metadata | Mặc định của profile |
| Driver | `psycopg[binary,pool]` | 3.3.6 | Driver PostgreSQL async, pool kết nối | Mặc định của profile |
| Cơ sở dữ liệu | PostgreSQL | 18.6 | Lưu trữ quan hệ, transaction ACID | Mặc định của profile |
| Logging | `structlog` | 26.1.0 | Log JSON một dòng, gắn correlation ID theo context | Mặc định của profile |
| Xác thực | `pyjwt` | 2.14.0 | Ký và kiểm tra access token | Mặc định của profile |
| Hash mật khẩu | `argon2-cffi` | 25.1.0 | Argon2id | Mặc định của profile |
| Giới hạn tần suất | `limits` | 5.8.0 | Cửa sổ trượt, storage trong tiến trình hoặc Redis khi nhiều instance | Mặc định của profile |
| Test | `pytest` | 9.1.1 | Chạy test | Mặc định của profile |
| Test | `pytest-asyncio` | 1.4.0 | Test async, chế độ `auto` | Mặc định của profile |
| Test | `pytest-cov` | 7.1.0 | Coverage dòng và nhánh | Mặc định của profile |
| Test | `httpx` | 0.28.1 | Client e2e gọi ứng dụng qua `ASGITransport`, không mở cổng | Mặc định của profile |
| Test | `testcontainers[postgres]` | 4.15.0 | PostgreSQL chạy cô lập cho integration, e2e, `CONC` | Mặc định của profile |
| Test | `jsonschema`, `types-jsonschema` | 4.26.0, 4.26.0.20260518 | Test `CTR` đối chiếu phản hồi với schema trong tài liệu OpenAPI | Mặc định của profile |
| Lint và định dạng | `ruff` | 0.16.8 | Lint và định dạng, thay cho bộ flake8 cộng black | Mặc định của profile |
| Typecheck | `mypy` | 2.3.1 | Kiểm kiểu ở chế độ `strict` | Mặc định của profile |
| Audit | `pip-audit` | 2.10.1 | Đối chiếu dependency đã khóa với cơ sở dữ liệu lỗ hổng | Mặc định của profile |
| Tài liệu API | `openapi-spec-validator` | 0.9.0 | Kiểm `openapi/openapi.yaml` theo OpenAPI 3.1, không cần Node.js | Mặc định của profile |
| Tài liệu API | `pyyaml`, `types-pyyaml` | 6.0.3, 6.0.12.20260906 | Ghi và đọc tài liệu OpenAPI dạng YAML; stub kiểu cho mypy | Mặc định của profile |

## 3. Giá trị placeholder

| Placeholder | Giá trị |
| --- | --- |
| `{{LANGUAGE_STRICT_MODE_RULE}}` | `mypy` chạy `strict` cho `src/` và `tests/`; `ruff` bật nhóm `ANN` nên mọi hàm phải có annotation và `Any` trong annotation bị chặn; `Any` chỉ dùng ở ranh giới serialize JSON. |
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

Ghi chú:

- FastAPI sinh tài liệu OpenAPI từ mã, nên `{{CODEGEN_CMD}}` là bước xuất tài liệu đó ra `openapi/openapi.yaml` chứ không sinh mã. Lệnh chạy trước mọi lệnh khác và chạy lại sau mỗi lần đổi router hoặc DTO; file kết quả được commit để so khác biệt trong review và để test `CTR` đối chiếu.
- Hai lệnh migration chỉ cần biến `DATABASE_URL`, không cần biến nào khác của ứng dụng, nên job migration lúc phát hành không phải mang theo secret của ứng dụng.
- `{{MIGRATION_CHECK_CMD}}` cần một cơ sở dữ liệu đang chạy và đã `upgrade head`: `alembic check` so metadata của ORM với schema thật và trả khác 0 khi còn thay đổi chưa có migration. Ở CI, chạy trên cơ sở dữ liệu dùng một lần của job.
- `uv run` tự đồng bộ môi trường theo `uv.lock` trước khi chạy, nên không cần bước cài riêng; CI dùng `uv sync --frozen` để lỗi khi lock không khớp `pyproject.toml`.
- `pip-audit` đọc môi trường đã khóa; `--strict` làm cảnh báo thành lỗi. Lỗ hổng không có bản vá thì ghi ADR chấp nhận rủi ro và thêm `--ignore-vuln <id>` kèm ngày xem lại.
- Ngưỡng coverage mặc định của profile là 80% dòng và nhánh cho `src/app/`, đo bằng cấu hình `[tool.coverage.run]`; SRS có thể đặt ngưỡng khác ở NFR-MAINT.
- Test dùng `testcontainers`, nên máy chạy test cần Docker. Môi trường không có Docker thì đặt biến trỏ tới một PostgreSQL dùng một lần và ghi cách làm vào ARCHITECTURE §11.
- Chạy ứng dụng khi phát triển: `uv run uvicorn --factory app.main:create_app --port 8000`; sau reverse proxy thì thêm `--proxy-headers --forwarded-allow-ips <IP của proxy>` để địa chỉ client trong log và trong bộ đếm giới hạn tần suất là địa chỉ thật.

## 4. Nội dung chèn vào tài liệu (Profile Content)

### 4.1. Cây thư mục và cấu hình công cụ (cho ARCHITECTURE §4)

<!-- PROFILE-CONTENT: arch.layout -->
### Cây thư mục theo stack (Stack Directory Tree)

```text
.
├── pyproject.toml                       # dependency, cấu hình ruff, mypy, pytest, coverage, build
├── uv.lock                              # khóa toàn bộ cây dependency, commit vào repo
├── .python-version                      # bản CPython chính xác, uv đọc file này
├── .env.example                         # tên mọi biến môi trường kèm giá trị mẫu, không chứa giá trị thật
├── alembic.ini                          # cấu hình Alembic, script_location và prepend_sys_path
├── openapi/openapi.yaml                 # tài liệu OpenAPI 3.1 xuất từ ứng dụng, commit vào repo
├── migrations/
│   ├── env.py                           # nạp metadata của ORM, chạy migration trên engine async
│   ├── script.py.mako                   # khuôn file migration, đã sửa cho ruff và kiểu hiện đại
│   └── versions/                        # migration đã sinh, không sửa sau khi đã chạy ở môi trường khác
├── src/app/
│   ├── main.py                          # create_app: middleware, exception handler, router, lifespan, openapi
│   ├── config.py                        # nơi duy nhất đọc biến môi trường, và dependency đọc cấu hình
│   ├── openapi_export.py                # ghi tài liệu OpenAPI ra openapi/openapi.yaml
│   ├── db/
│   │   ├── base.py                      # DeclarativeBase và quy ước đặt tên ràng buộc
│   │   └── session.py                   # engine, session factory, dependency một session mỗi request
│   ├── lib/
│   │   ├── envelope.py                  # envelope thành công theo ARCHITECTURE §6.2
│   │   ├── errors.py                    # error code của Registry, ánh xạ HTTP status, envelope lỗi
│   │   ├── logging.py                   # cấu hình structlog và middleware correlation ID
│   │   ├── security.py                  # hash mật khẩu, ký và đọc token, scheme bearer cho OpenAPI
│   │   └── rate_limit.py                # dependency giới hạn tần suất và header RateLimit-*
│   └── modules/{{MODULE_SLUG}}/
│       ├── router.py                    # APIRouter, khai báo endpoint, mã phản hồi và response model
│       ├── schemas.py                   # DTO request và response bằng Pydantic
│       ├── service.py                   # quy tắc nghiệp vụ, ranh giới transaction, idempotency
│       ├── repository.py                # truy vấn SQLAlchemy, không chứa quy tắc nghiệp vụ
│       └── model.py                     # bảng của phân hệ, mapping có kiểu
└── tests/
    ├── conftest.py                      # fixture container PostgreSQL, session, client, dọn bảng
    ├── unit/                            # hàm thuần, không chạm cơ sở dữ liệu
    ├── integration/                     # service và repository trên cơ sở dữ liệu thật
    ├── e2e/                             # gọi ứng dụng qua ASGITransport của httpx, gồm test CTR
    └── concurrency/                     # test CONC, nhiều request song song trên một bất biến
```

Với stack này `{{MODULE_SLUG}}` viết `snake_case` số nhiều, vì tên thư mục cũng là tên package Python và dấu gạch ngang không hợp lệ.

Cấu hình công cụ nằm cùng một file `pyproject.toml`:

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

File Diff mặc định khi SPEC thêm một endpoint ghi: `router.py`, `schemas.py`, `service.py`, `repository.py`, `model.py` của phân hệ, một file trong `migrations/versions/`, `openapi/openapi.yaml`, và test của các loại trong `tests/`.
<!-- /PROFILE-CONTENT -->

### 4.2. Schema SQLAlchemy và Alembic (cho ARCHITECTURE §5)

<!-- PROFILE-CONTENT: arch.schema -->
### Quy ước schema SQLAlchemy (SQLAlchemy Schema Conventions)

Lớp cơ sở khai báo quy ước đặt tên, để migration đặt tên ràng buộc giống nhau trên mọi môi trường và `alembic check` so sánh được:

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

| Khái niệm | Cách viết trong SQLAlchemy |
| --- | --- |
| Tên lớp và bảng | Lớp `PascalCase` số ít cho `{{ENTITY_NAME}}`, `__tablename__` là `snake_case` số nhiều |
| Cột | `title: Mapped[str] = mapped_column(String(200))`; kiểu Python quyết định `nullable`, nên `Mapped[str | None]` nghĩa là cột cho phép rỗng |
| Khóa chính UUID | `mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)` |
| Chuỗi | `String(n)` với `n` khớp ràng buộc ở DTO; `Text()` chỉ khi DTO cũng không giới hạn độ dài |
| Tiền tệ | `Numeric(12, 2)`, đọc ra `decimal.Decimal`, không dùng `float` |
| Thời gian | `DateTime(timezone=True)` với `server_default=func.now()`; cột sửa lần cuối thêm `onupdate=func.now()` |
| Enum | `String(n)` cộng `CheckConstraint` liệt kê giá trị `UPPER_SNAKE`, khớp SRS §4.2; kiểu `ENUM` của PostgreSQL cần ADR vì đổi giá trị phải migration |
| Ràng buộc kiểm tra | `__table_args__ = (CheckConstraint("...", name="..."),)`, tên ngắn vì quy ước đặt tên thêm tiền tố bảng |
| Khóa ngoại | `mapped_column(ForeignKey("parents.id", ondelete="RESTRICT"), index=True)`, tên bảng cha viết số nhiều như `__tablename__` của nó |
| Duy nhất ghép | `UniqueConstraint("a", "b")` trong `__table_args__` |
| JSON | `JSONB()` của phương ngữ PostgreSQL, kiểu Python là `dict[str, Any]` |

`migrations/env.py` chỉ đọc biến kết nối và tạo engine thẳng từ giá trị đó. Không đẩy URL qua `config.set_main_option`: configparser nội suy dấu `%`, nên mật khẩu percent-encode làm lệnh migration chết với `ValueError: invalid interpolation syntax`. Nạp cả lớp `Settings` của ứng dụng cũng không được, vì khi đó job migration lúc phát hành phải mang theo mọi secret của ứng dụng.

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

Quy tắc còn lại:

- `migrations/env.py` import `Base` và mọi module `model` để metadata đủ bảng.
- `alembic revision --autogenerate` chỉ là bản nháp: đọc lại file sinh ra, thêm chỉ mục thiếu và câu SQL cho dữ liệu, rồi mới commit.
- `compare_type=True` trong `context.configure` để đổi kiểu cột không bị bỏ sót; đây là thứ làm `{{MIGRATION_CHECK_CMD}}` bắt được thay đổi độ dài chuỗi.
- Migration đã chạy ở môi trường khác thì không sửa; viết migration mới.
<!-- /PROFILE-CONTENT -->

### 4.3. Quy ước giao tiếp của stack (cho ARCHITECTURE §7)

<!-- PROFILE-CONTENT: arch.conventions -->
### Hiện thực quy ước theo stack (Stack Implementation Notes)

- `create_app(settings)` trong `src/app/main.py` là nơi duy nhất dựng ứng dụng: gắn middleware correlation ID, đăng ký exception handler cho lỗi nghiệp vụ và lỗi validate, include router của từng phân hệ, mở engine trong `lifespan` rồi `dispose` khi tắt, và ghi đè `app.openapi()` để tài liệu xuất ra đúng hợp đồng. Test dựng ứng dụng bằng chính hàm này với `Settings` riêng.
- Cấu hình đọc một lần bằng `pydantic-settings`; dependency đọc lại từ `app.state`, không đọc biến môi trường trong route, nhờ vậy test tiêm được cấu hình:

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

- Một session cho mỗi request, lấy từ session factory nằm trong `app.state`; mức isolation đặt ở engine:

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

- Ranh giới transaction nằm ở service: đọc và ghi của một thao tác chạy trong transaction ngầm mà session đã mở, và service gọi `await session.commit()` đúng một lần ở cuối. Không gọi `session.begin()` sau khi đã có câu truy vấn trong session, vì SQLAlchemy đã mở transaction từ câu đó và lời gọi thứ hai ném `InvalidRequestError`.
- Idempotency cho thao tác ghi: một bảng giữ khóa, vân tay của body và bản phản hồi đã trả. Lần gửi lại với cùng khóa đọc lại phản hồi cũ; cùng khóa mà body khác thì trả mã lỗi của Registry. Hai request song song cùng khóa thì khóa chính của bảng làm request thua cuộc nhận `IntegrityError`, service bắt lỗi đó, rollback và đọc lại phản hồi của request thắng.
- Mọi phản hồi thành công bọc trong envelope của ARCHITECTURE §6.2; route khai báo kiểu trả về là `Envelope[...]` nên tài liệu OpenAPI mang đúng hình dạng này:

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

- <!-- fill: liệt kê đúng mã lỗi của Error Code Registry ở ARCHITECTURE §7.1; bảng dưới là phần mẫu --> Mã lỗi khai báo một chỗ cùng HTTP status, và lỗi nghiệp vụ là một exception mang mã đó; envelope lỗi có `timestamp` và `details` là danh sách `{field, issue}`:

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

- Handler của `AppError` trả envelope lỗi kèm `correlationId` và các header mà lỗi mang theo; handler của `RequestValidationError` trả mã `VALIDATION_ERROR` với danh sách trường sai, để lỗi validate của FastAPI không lọt ra ngoài dưới dạng `422` mặc định.
- `app.openapi()` được ghi đè để xóa response `422` mà FastAPI tự thêm, giữ tài liệu khớp ma trận lỗi của SPEC. `FastAPI(...)` khai báo `servers`, `license_info`, `responses` chung cho mã lỗi mọi route có thể trả, và `generate_unique_id_function` sinh `operationId` dạng `camelCase`.
- Log là JSON một dòng bằng `structlog`; middleware nhận `X-Correlation-Id` của người gọi hoặc sinh mới, gắn vào context và trả lại trong header phản hồi. Không log token, mật khẩu hay dữ liệu cá nhân.
- Giới hạn tần suất là một dependency đếm theo chủ thể đã xác thực; mọi phản hồi mang ba header `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`, và lần bị từ chối thêm `Retry-After` tính từ cửa sổ hiện tại:

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

  Route công khai (chưa xác thực) đếm theo địa chỉ client thật: chạy `uvicorn` với `--proxy-headers --forwarded-allow-ips` của proxy tin cậy rồi lấy `request.client.host`. Nhiều instance thì đổi `MemoryStorage` sang storage dùng chung của `limits`, nếu không mỗi instance cấp trọn hạn mức.
- Xác thực dùng `pyjwt` với thuật toán `HS256` và hạn dùng ngắn; mật khẩu băm bằng Argon2id của `argon2-cffi`. Scheme `HTTPBearer(auto_error=False)` vừa sinh `securitySchemes` trong tài liệu OpenAPI, vừa để header thiếu trở thành envelope `UNAUTHENTICATED` của dự án thay vì thân lỗi mặc định của FastAPI.
<!-- /PROFILE-CONTENT -->

### 4.4. Khuôn DTO (cho SPEC §3)

<!-- PROFILE-CONTENT: spec.contract -->
### DTO với Pydantic (Pydantic DTO Schema)

<!-- fill: thay tên trường và ràng buộc theo DTO của tính năng; khối dưới là phần mẫu -->

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

- `extra="forbid"` ở request nên trường lạ bị từ chối thay vì bị bỏ qua.
- Tên trường trong Python là `snake_case`; JSON ra ngoài dùng `camelCase` qua `serialization_alias`, khớp quy ước envelope ở ARCHITECTURE §6.2.
- `from_attributes=True` cho response để dựng thẳng từ đối tượng ORM.
- Ràng buộc độ dài và miền giá trị ghi ngay trong kiểu (`StringConstraints`, `Literal`, `Field(ge=..., le=...)`), nên tài liệu OpenAPI sinh ra mang đúng ràng buộc của SPEC.
- Route khai báo kiểu trả về `Envelope[{{ENTITY_NAME}}Response]` và các mã lỗi riêng của nó trong `responses`; fragment OpenAPI của SPEC (tệp đi kèm của SPEC) là phần cắt ra từ `openapi/openapi.yaml` đã xuất, không viết tay.
<!-- /PROFILE-CONTENT -->

### 4.5. Công cụ test (cho SPEC §9)

<!-- PROFILE-CONTENT: spec.test-types -->
### Công cụ và vị trí test theo stack (Stack Test Tooling)

| TYPE | Công cụ | File | Chạy bằng |
| --- | --- | --- | --- |
| `UNIT` | pytest, hàm thuần và lớp không chạm cơ sở dữ liệu | `tests/unit/test_*.py` | `{{UNIT_TEST_CMD}}` |
| `INT` | pytest, `testcontainers[postgres]`, session thật của SQLAlchemy | `tests/integration/test_*.py` | `{{INTEGRATION_TEST_CMD}}` |
| `E2E` | pytest, `httpx.AsyncClient` với `ASGITransport`, ứng dụng dựng bằng `create_app` | `tests/e2e/test_*.py` | `{{E2E_TEST_CMD}}` |
| `CTR` | Như `E2E`, lấy schema của phản hồi từ `openapi/openapi.yaml` đã xuất và kiểm bằng `jsonschema` | `tests/e2e/test_contract.py` | `{{E2E_TEST_CMD}}` |
| `CONC` | pytest, `asyncio.gather` gửi N request song song, rồi truy vấn khẳng định bất biến | `tests/concurrency/test_*.py` | `{{E2E_TEST_CMD}}` |
| `LOAD` | Công cụ chọn bằng ADR khi SPEC cần | Ngoài `tests/` | Không thuộc pytest |

Fixture dùng chung nằm ở `tests/conftest.py`: một container PostgreSQL cho cả phiên test, `Settings` của môi trường test, session factory đã tạo bảng, một session cho mỗi test, client `httpx` mang sẵn token, và một fixture tự chạy dọn sạch bảng sau mỗi test.

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

`asyncio_mode = "auto"` nên test async không cần decorator. Tên test mô tả hành vi bằng tiếng Anh, ví dụ `def test_a_request_without_a_token_is_refused(...)`; không chứa TC ID.
<!-- /PROFILE-CONTENT -->

## 5. Quy ước riêng của stack (Stack Conventions)

- `src/` layout: mã nằm trong `src/app/`, khai báo ở `[tool.uv.build-backend]` với `module-name = "app"` và `module-root = "src"`; `pythonpath = ["src"]` của pytest cho test import thẳng từ cây nguồn.
- `uv.lock` và `.python-version` commit vào repo; CI chạy `uv sync --frozen` để phát hiện lock cũ.
- Tên thư mục phân hệ là `snake_case` số nhiều vì nó cũng là tên package Python; ngoại lệ này của `{{MODULE_SLUG}}` ghi luôn vào ARCHITECTURE §4 khi ghép.
- Lint và định dạng chạy cho cả `migrations/`; chỉ thân file trong `migrations/versions/` được miễn nhóm `ANN` vì khuôn của Alembic sinh phần thân không annotation, và `mypy` bỏ qua đúng thư mục đó.
- Mọi hàm async chạm mạng hoặc cơ sở dữ liệu đều có annotation trả về; `ruff` nhóm `ASYNC` bắt lệnh chặn vòng lặp sự kiện, ví dụ đọc file bằng `pathlib` trong hàm async.
- `ruff` nhóm `S` (bandit) bật cho `src/`; `tests/` bỏ qua `S101` vì test dùng `assert`.
- Không dùng `print`; mọi bản ghi đi qua logger của `structlog`.
- `mypy` ở chế độ `strict` cần `# type: ignore[call-arg]` khi khởi tạo `Settings` không tham số (mọi giá trị đến từ môi trường) và `# type: ignore[arg-type]` khi truyền chuỗi vào trường `PostgresDsn` trong test; giữ đúng hai chỗ đó, không nới `strict`.

## 6. Khởi tạo dự án (Project Setup)

1. Cài `uv` 0.12.18, rồi `uv python install 3.13` và `uv python pin 3.13.13` để ghim đúng runtime của profile.
2. `uv init --package <tên>` rồi sửa dự án cho khớp cây ở mục 4.1: đổi `src/<tên>` thành `src/app`, thêm `[tool.uv.build-backend]` với `module-name = "app"` và `module-root = "src"`, gỡ khối `[project.scripts]` mà scaffold sinh ra, đặt `requires-python = "==3.13.*"`.
3. Thêm dependency với phiên bản chính xác ở mục 2, ví dụ `uv add "fastapi==0.141.1" "sqlalchemy[asyncio]==2.0.54" "psycopg[binary,pool]==3.3.6" "alembic==1.20.0" "pydantic-settings==2.15.0"`, và nhóm dev bằng `uv add --dev "pytest==9.1.1" "ruff==0.16.8" "mypy==2.3.1"`.
4. Chép các khối cấu hình ở mục 4.1 vào `pyproject.toml`, và tạo `.env.example` liệt kê mọi biến môi trường kèm giá trị mẫu.
5. `uv run alembic init -t async migrations`, rồi sửa: `alembic.ini` đặt `prepend_sys_path = src`, `script_location = migrations`, `timezone = UTC`; giữ `%%` trong `file_template` (configparser nội suy) nhưng giữ `%` đơn trong `[formatter_generic] format`, vì nhân đôi ở đó làm log in ra chính chuỗi định dạng; `migrations/env.py` viết lại theo mục 4.2; `migrations/script.py.mako` đổi `from typing import Sequence` thành `from collections.abc import Sequence` và `Union[str, None]` thành `str | None` để file sinh ra qua được `ruff`.
6. Tạo `src/app/` theo cây ở mục 4.1, viết `create_app`, cấu hình, session, envelope, lỗi, log, bảo mật, giới hạn tần suất trước khi viết phân hệ đầu tiên.
7. Chạy `{{CODEGEN_CMD}}` rồi lần lượt các lệnh verify còn lại để xác nhận môi trường đủ (Docker cho `testcontainers`, PostgreSQL và biến `DATABASE_URL` cho hai lệnh migration).
