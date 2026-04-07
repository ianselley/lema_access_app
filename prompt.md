Quiero que actúes como el orquestador principal de backend para el MVP de la app móvil **LEMA Access**.

## Contexto de producto

LEMA Access es la app operativa de staff para acceso a eventos. Hoy el foco es el escaneo y validación de tickets, pero el nombre no es “scanner” porque en el futuro incluirá más capacidades operativas.

La app es para iOS y Android. El login inicial es **solo con correo y contraseña**. Todo usuario de la app tiene una fila en `public.profile`. Los escaneadores tienen acceso a eventos a través de `ticketing.event_member`.

La UI ya tiene definidas estas áreas principales:

- login
- lista de eventos asignados
- home de evento
- escáner
- resultados de escaneo
- entrada manual de código
- búsqueda manual de tickets
- detalle de ticket
- confirmación de validación manual
- historial reciente
- perfil / sesión mínima

Tú tienes acceso al estado de la UI y puedes leer todo el backend y el schema real con el mcp local de supabase.

## Principio rector

**Prevalece el backend.**
No fuerces el backend para acomodar una UI incorrecta. Si la UI presupone algo que no encaja con el modelo de datos, ajusta la UI al contrato de backend correcto. La app cliente debe adaptarse al backend, no al revés.

## Reglas obligatorias

- Antes de construir nada, haz una **orquestación inicial** para que los subagentes no se pisen.
- Para **cada función** que haga falta, crea un **subagente** específico que se encargue de implementarla junto con su contrato, validaciones, RLS/seguridad, índices y tests.
- Tú, como orquestador, reservas primero:
  - nombres de funciones
  - firma de argumentos
  - shape de respuesta
  - ownership de tablas / vistas auxiliares / migraciones
  - orden de despliegue
- Alcance de este prompt: **limítate a backend SQL** (funciones Postgres, tablas, índices, permisos/RLS, tests y contratos `jsonb`). **No implementes integración en el frontend** (servicios, providers, repositorios, hooks, DI, etc.). Esa integración se hará en un agente separado usando los contratos definidos aquí.
- Todas las funciones Postgres nuevas:
  - deben usar argumentos con nombre que empiece por `p_`
  - deben devolver `jsonb`
  - deben declarar `set search_path = ''`
- Al referenciar tablas, usa siempre schema explícito:
  - `public.profile`
  - `ticketing.event`
  - etc.
- No asumas que el schema pegado aquí está perfecto. **Inspecciona el schema real** y corrige incoherencias si las hay.
- No hagas escrituras directas desde cliente a tablas sensibles. Todo write crítico debe pasar por funciones backend.
- Mantén los nombres de funciones y claves JSON siempre en inglés, pero recuerda que la UI visible al usuario irá en español.
- Si necesitas referenciar el cliente de Supabase, hazlo solo a nivel de **contrato/expectativas** (p. ej. qué RPCs y shapes usará). **No crees archivos ni servicios del frontend** en este paso.

## Lo primero que debes hacer

### 1. Orquestación inicial

Haz primero un plan corto pero claro con:

- listado final de funciones
- dependencias entre ellas
- índices nuevos necesarios
- decisiones de concurrencia
- decisiones de auditoría
- taxonomy de estados para la app

### 2. Detecta huecos del modelo

A simple vista, para cubrir el historial y la trazabilidad de escaneos, probablemente faltará al menos una tabla de auditoría tipo:

- `ticketing.ticket_scan_log` o equivalente

Valida si hace falta crearla. Muy probablemente sí, porque `ticketing.ticket.checked_in_at` no basta para:

- saber quién escaneó
- registrar intentos fallidos
- poblar historial reciente
- resolver disputas
- distinguir escaneo vs validación manual
- guardar input original / resultado / motivo

Si detectas más huecos estructurales, propón el mínimo cambio necesario.

Cuando confirmes que hace falta histórico/auditoría, usa el MCP de Supabase para **ir creando archivos de migración** (SQL) que dejen ese histórico listo (tabla(s), índices, constraints y permisos/RLS si aplica), en vez de dejarlo implícito o solo descrito.

## Estándar de respuesta

Todas las funciones deberían devolver un `jsonb` con los campos necesarios para el modelo del frontend

## Lista objetivo de funciones para el MVP

Estas son las funciones que, salvo que el schema real te obligue a refinar algo, deberías implementar o confirmar como necesarias.

### 1. `ticketing.access_get_bootstrap(...)`

**Objetivo:** hidratar la app al abrirse.
Debe devolver la información mínima para decidir routing inicial:

- profile actual
- si existe `public.profile`
- permisos de acceso
- eventos accesibles resumidos o al menos conteo
- posible evento activo/reciente si aplica
- flags útiles para la app

**Pantallas:** splash, bootstrap, session restore.

---

### 2. `ticketing.access_get_me(...)`

**Objetivo:** devolver el perfil actual de LEMA Access.
Debe servir para la pantalla de perfil / sesión mínima.
Puede incluir:

- `public.profile`
- email del usuario
- roles agregados
- versión mínima o flags si te parece útil

**Pantallas:** perfil, ajustes mínimos, sesión.

---

### 3. `ticketing.access_get_events(...)`

**Objetivo:** listar solo los eventos a los que el usuario autenticado tiene acceso por `ticketing.event_member`.
Debe combinar correctamente:

- `ticketing.event`
- `public.party` (porque `ticketing.event.id -> public.party.id`)
- `public.brand`
- rol del usuario en el evento
- estado operativo
- métricas resumidas útiles para la card

**Pantallas:** lista de eventos asignados.

---

### 4. `ticketing.access_get_event_home(...)`

**Objetivo:** devolver el payload completo del home operativo de un evento.
Debe incluir:

- datos del evento
- datos display del party/brand
- rol del usuario
- contadores básicos
- resumen de tickets emitidos / validados si procede
- últimos movimientos o timestamp de última actividad si es útil
- estado operativo mínimo para pintar la home

**Pantallas:** home de evento.

---

### 5. `ticketing.access_resolve_scan_input(...)`

**Objetivo:** normalizar una entrada de escaneo sin mutar todavía, cuando sea necesario.
Debe aceptar un raw input y decidir si corresponde a:

- `scan_token`
- `code`
- otro formato soportado

Debe devolver:

- ticket encontrado o no
- evento correcto o no
- estado actual del ticket
- si sería potencialmente validable

Esta función es útil para separar “resolver” de “confirmar”, especialmente en casos manuales o si la UI necesita previsualización antes de confirmar.

**Pantallas:** escáner, entrada manual, búsqueda/resolución de incidencias.

---

### 6. `ticketing.access_check_in_from_scan(...)`

**Objetivo:** hacer el check-in atómico a partir del input escaneado o tecleado.
Esta es una de las funciones más críticas.

Debe:

- verificar permiso del usuario en el evento
- resolver el input
- bloquear correctamente el ticket o la fila necesaria para evitar dobles validaciones concurrentes
- validar estado del ticket
- actualizar `ticketing.ticket`
- dejar trazabilidad completa en la tabla de log/auditoría
- devolver un resultado listo para la UI

Debe contemplar al menos estos resultados:

- valid
- already_used
- cancelled_or_invalid
- not_found
- wrong_event
- forbidden
- temporary_error

**Pantallas:** escáner, entrada manual, resultados de escaneo.

---

### 7. `ticketing.access_check_in_ticket(...)`

**Objetivo:** hacer check-in atómico a partir de un `ticket_id` ya resuelto.
Sirve para validación manual desde detalle, sin pasar otra vez por raw scan input.

Debe reutilizar la misma lógica de integridad, permisos, concurrencia y logging que la función anterior.

**Pantallas:** detalle de ticket, confirmación de validación manual.

---

### 8. `ticketing.access_search_event_tickets(...)`

**Objetivo:** buscar tickets dentro de un evento.
Debe permitir query por combinaciones razonables de:

- nombre
- email
- teléfono
- code
- order reference

Debe devolver resultados suficientemente desambiguados para UI.
No busques globalmente entre eventos; el contexto del evento importa.

**Pantallas:** búsqueda manual, resultados de búsqueda.

---

### 9. `ticketing.access_get_ticket_detail(...)`

**Objetivo:** devolver el detalle operativo de un ticket dentro de un evento.
Debe incluir:

- identidad del asistente
- tipo de ticket
- estado
- referencias de pedido
- timestamps relevantes
- si es validable o no
- información suficiente para resolver incidencias

**Pantallas:** detalle de ticket, confirmación manual, resultados enriquecidos.

---

### 10. `ticketing.access_event_scan_history(...)`

**Objetivo:** devolver el historial reciente de escaneos/intentos de un evento.
Esto requiere casi seguro la tabla de auditoría mencionada antes.

Debe soportar:

- paginación simple
- filtro opcional por tipo de resultado
- orden por recencia

Debe devolver:

- resultado del intento
- ticket si aplica
- asistente si aplica
- quién escaneó
- cuándo
- source (scan/manual)
- motivo o code de error si aplica

**Pantallas:** historial reciente, resolución de disputas.

---

### 11. `ticketing.access_scan_log_detail(...)` _(solo si realmente hace falta)_

**Objetivo:** detalle de una entrada concreta del historial si la UI o la operativa lo necesita.
No la crees por defecto si el historial ya devuelve suficiente contexto.

**Pantallas:** solo si acabara habiendo drill-down en historial.

## Edge Functions

Para este MVP, intenta mantenerlo **SQL-first** y no metas Edge Functions si no aportan una ventaja clara.

### No necesarias de inicio

- login con email/password: usa Supabase Auth, no hace falta Edge Function propia
- logout: cliente/Auth
- conectividad: cliente
- refresh de sesión: cliente/Auth

### Edge Function opcional 1: `access-scan`

Solo créala si descubres que realmente hace falta una capa server-side extra para:

- parsing complejo de QR
- rate limiting
- validación criptográfica del payload
- telemetría adicional
- encapsular lógica no razonable en SQL

Si no hay esa necesidad clara, **no la crees** y mantén el check-in en función Postgres.

### Edge Function opcional 2: `access-forgot-password-proxy`

Solo si por UX o seguridad necesitáis encapsular un flujo especial. En principio no parece necesaria.

## Consideraciones de datos y relaciones

Piensa bien estas relaciones:

- todo usuario de la app existe en `public.profile`
- permisos de acceso por evento en `ticketing.event_member`
- `ticketing.event.id` referencia `public.party.id`
- el branding viene de `ticketing.event.brand_id -> public.brand.id`
- tickets ligados a attendees y orders
- el escaneo debe respetar siempre el contexto del evento
- el historial debe registrar intentos válidos e inválidos
- el actor del escaneo debe quedar registrado
- la UI no debería inventar estados que el backend no pueda sostener

## Cosas que debes revisar sí o sí

- índices para búsqueda y escaneo
- unicidad real de membresías por evento/usuario si falta
- índices por `ticketing.ticket.event_id + code`
- índices por `ticketing.ticket.event_id + scan_token`
- consistencia de FKs y constraints reales
- RLS y/o `security definer` según corresponda
- shape homogéneo de errores
- idempotencia y concurrencia del check-in
- tests de doble escaneo simultáneo
- tests de usuario sin permisos
- tests de evento equivocado
- tests de ticket ya usado
- tests de ticket cancelado / inválido
- tests de not found

## Entrega esperada

1. Primero: plan de orquestación inicial.
2. Después: lista final cerrada de funciones, tablas nuevas e índices.
3. Después: un subagente por función.
4. Cada subagente debe implementar:
   - migración si hace falta
   - función
   - permisos / seguridad
   - tests
   - contrato de respuesta
5. Si algo de la UI no encaja con el backend correcto, propones el ajuste de UI.
6. La integración con el frontend (servicios/providers y wiring del cliente) se hará **después** con un agente dedicado. Aquí solo debe quedar listo el backend y sus contratos.

## Importante

No necesito que sobre-analices aquí el producto. Vas a poder leer el backend real. Quiero que uses este prompt como marco de ejecución para aterrizar rápidamente el MVP backend completo de LEMA Access sin que los agentes se pisen entre sí.
