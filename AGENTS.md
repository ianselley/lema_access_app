- When checking backend-related behavior, data, schema, functions, policies, or migrations, use the local Supabase MCP whenever possible.
- Add database migrations in the `lema-backend` repo, not in this web repo.

## Compatibilidad de base de datos

- Trata la versión publicada de LEMA Access como un cliente activo y desconocido. Los cambios de base de datos deben ser compatibles hacia atrás: no elimines ni renombres RPCs, parámetros, campos JSON, valores de enum, tablas o permisos que la app pueda usar.
- Para ampliar un contrato RPC, añade campos o parámetros opcionales con defaults que conserven exactamente el comportamiento anterior. Despliega primero la migración compatible y después la app que consume el nuevo contrato.
- Antes de cambiar una función usada por Access, revisa sus llamadas y modelos en `lib/src/services` y `lib/src/models`; verifica también mediante el MCP local que la firma y las claves JSON existentes se mantienen.
- Si un cambio incompatible es inevitable, no lo ocultes ni lo minimices: al terminar el turno avisa de forma destacada y explícita que la migración obliga a desplegar una nueva versión de LEMA Access, identifica la migración y especifica el orden de despliegue seguro.
