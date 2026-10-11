# Smells and Refactorings

Each smell is a hint that the structure is in the way, with the named refactorings that usually fix it - smell and refactoring names from Martin Fowler's *Refactoring* (2nd edition). The examples are this stack's: routes handle HTTP only, services take a `Session` and raise `DomainError`, the frontend uses signals and calls the API only through the generated client. A smell is a reason to look, not a rule: leave it where the code isn't in anyone's way.

| Smell | Usual refactorings |
|-------|--------------------|
| [Mysterious Name](#mysterious-name) | Rename Variable, Change Function Declaration, Rename Field |
| [Duplicated Code](#duplicated-code) | Extract Function, Slide Statements, Pull Up Method |
| [Long Function](#long-function) | Extract Function, Decompose Conditional, Replace Temp with Query |
| [Long Parameter List](#long-parameter-list) | Introduce Parameter Object, Preserve Whole Object |
| [Global Data](#global-data) | Encapsulate Variable |
| [Mutable Data](#mutable-data) | Separate Query from Modifier, Replace Derived Variable with Query |
| [Divergent Change](#divergent-change) | Split Phase, Extract Class |
| [Shotgun Surgery](#shotgun-surgery) | Move Function, Combine Functions into Class |
| [Feature Envy](#feature-envy) | Move Function |
| [Data Clumps](#data-clumps) | Introduce Parameter Object, Extract Class |
| [Primitive Obsession](#primitive-obsession) | Replace Primitive with Object |
| [Repeated Switches](#repeated-switches) | Replace Conditional with Polymorphism |
| [Message Chains](#message-chains) | Hide Delegate |
| [Speculative Generality](#speculative-generality) | Collapse Hierarchy, Inline Function, Remove Dead Code |
| [Logic in the Wrong Layer](#logic-in-the-wrong-layer) | Move Function, Extract Function |

---

## Mysterious Name

A name that needs a comment to explain it. Rename first: most other smells get easier to see once names say what things are.

```python
# Before
def proc(d, f=False): ...
# After - Change Function Declaration
def archive_workspace(workspace_id: UUID, *, notify_members: bool = False): ...
```

Renaming a route's path, a response field or an event type is not a refactoring for its clients - it's a breaking change. See SKILL.md section 5.

## Duplicated Code

The same shape in two places, so a fix lands in one and not the other.

```python
# Before - two services build the same query
q = select(Project).where(Project.workspace_id == ws_id, Project.archived_at.is_(None))
# After - Extract Function, called from both
def active_projects(ws_id: UUID) -> Select:
    return select(Project).where(Project.workspace_id == ws_id, Project.archived_at.is_(None))
```

Before extracting, check the two copies really mean the same thing. Code that looks alike but changes for different reasons should stay apart.

## Long Function

You need to read it twice to know what it does. Extract each block that has a name - a comment above a block is usually that name.

```python
# Before
def invite(session, ws, email, role):
    # check seats
    used = session.scalar(select(func.count()).where(Member.workspace_id == ws.id))
    if used >= ws.plan.seats:
        raise SeatLimitReached("No seats left")
    ...
# After - Extract Function
def invite(session, ws, email, role):
    _require_free_seat(session, ws)
    ...
```

## Long Parameter List

Callers pass the same five arguments in the same order, and get them wrong.

```python
# Before
def search(session, ws_id, text, status, owner_id, limit, cursor): ...
# After - Introduce Parameter Object: the route's query model is already one
class ProjectSearch(BaseModel):
    text: str | None = None
    status: Status | None = None
    owner_id: UUID | None = None
def search(session, ws_id, criteria: ProjectSearch, page: Page): ...
```

## Global Data

A module-level value anything can change, so nobody can say who changed it.

```python
# Before
current_tenant = None          # set by middleware, read everywhere
# After - Encapsulate Variable: one getter, one setter, then narrow who calls the setter
_tenant: ContextVar[UUID | None] = ContextVar("tenant", default=None)
def current_tenant() -> UUID: ...
```

Settings are read once into one class ([API Structure](../../../docs/guides/API-STRUCTURE-GUIDE.md) choice 8); a module that reads `os.environ` itself is this smell.

## Mutable Data

A value updated in several places, or a function that both answers a question and changes state.

```typescript
// Before - a field kept in step by hand
total = 0;
add(item: Item) { this.items.push(item); this.total += item.price; }
// After - Replace Derived Variable with Query, as a computed signal
readonly items = signal<Item[]>([]);
readonly total = computed(() => this.items().reduce((sum, i) => sum + i.price, 0));
```

## Divergent Change

One module changes for unrelated reasons - a new export format and a new pricing rule both touch it.

```python
# Before - parsing, calculating and formatting in one function
def usage_report(raw_rows) -> str: ...
# After - Split Phase: each phase has one reason to change
def usage_report(raw_rows) -> str:
    usage = parse_usage(raw_rows)
    totals = summarise(usage)
    return render_csv(totals)
```

## Shotgun Surgery

The opposite: one change touches many modules - adding a notification type means editing six files.

Move the scattered pieces next to each other (Move Function, Combine Functions into Class) until one change is one place. Where a guide keeps a closed list on purpose - audit actions, alert activity, flag registry - the list plus its guard test is the design, not the smell.

## Feature Envy

A function that reads more of another object's data than its own.

```python
# Before - in the billing service
def can_add_member(ws: Workspace) -> bool:
    return len(ws.members) < ws.plan.seats and ws.status == "active"
# After - Move Function, to where the data lives
class Workspace(Base):
    def has_free_seat(self) -> bool: ...
```

## Data Clumps

The same group of values travels together - `amount, currency`; `start, end`.

```python
# Before
def charge(amount: int, currency: str): ...
def refund(amount: int, currency: str): ...
# After - Introduce Parameter Object
@dataclass(frozen=True)
class Money:
    amount: int
    currency: str
```

## Primitive Obsession

Strings and ints standing in for things with rules - a status string compared by hand, an email nobody validates.

```python
# Before
if project.status == "archvied": ...      # a typo no test catches
# After - Replace Primitive with Object
class ProjectStatus(StrEnum):
    ACTIVE = "active"
    ARCHIVED = "archived"
```

A new value in a response enum is a breaking change for clients already in use ([SDK Generation](../../../docs/guides/SDK-GENERATION-GUIDE.md) choice 11).

## Repeated Switches

The same `if/elif` on a type in several places; a new type means finding them all.

```python
# Before - in the sender and again in the preview
if channel == "email": ...
elif channel == "slack": ...
# After - Replace Conditional with Polymorphism: one adapter per channel, chosen once
class Channel(Protocol):
    def send(self, message: Message) -> None: ...
CHANNELS: dict[str, Channel] = {"email": EmailChannel(), "slack": SlackChannel()}
```

## Message Chains

A caller walks a chain of objects to reach what it needs, so it breaks when any link changes.

```typescript
// Before - in a component template
{{ session.user().workspace().plan().name }}
// After - Hide Delegate: the service exposes what callers ask for
readonly planName = computed(() => this.session.user()?.workspace.plan.name ?? '');
```

## Speculative Generality

Hooks, parameters and base classes for cases that never came: one implementation behind an abstract base, a `strategy` argument always passed the same value.

Inline Function, Collapse Hierarchy, Remove Dead Code. An adapter with an in-process fake is not this smell: the fake is its second implementation ([API Structure](../../../docs/guides/API-STRUCTURE-GUIDE.md) choice 3).

## Logic in the Wrong Layer

Not one of Fowler's names - this stack's version of Feature Envy across layers.

```python
# Before - a rule in the route, so a worker or a script can't reuse it
@router.post("/v1/projects/{id}/archive")
def archive(id: UUID, session: SessionDep):
    project = session.get(Project, id)
    if project.archived_at:
        raise HTTPException(409, "Already archived")
    project.archived_at = now()
# After - Move Function into the service; the route only translates HTTP
@router.post("/v1/projects/{id}/archive")
def archive(id: UUID, session: SessionDep):
    projects.archive(session, id)          # raises AlreadyArchived, a DomainError
```

```typescript
// Before - a component building requests by hand
this.http.get<Project[]>('/v1/projects')
// After - through the generated client, the only way the frontend calls the API
const { data } = await listProjects({ query: { status: 'active' } });
```
