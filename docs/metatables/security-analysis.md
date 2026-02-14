# Security Analysis de Metatables

## Riscos mapeados
1. **Override global de métodos de classe**: tabelas de classe são globais e mutáveis em runtime.
2. **`__index` fallback complexo**: sequência `fieldmethods -> campos dinâmicos -> methods` pode mascarar bugs de digitação.
3. **Eventos por convenção (`on*`)**: qualquer chave começando com `on` vira evento marcado em `m_events`.
4. **Metatables Lua anônimas**: usos `setmetatable(obj, { __index = base })` dificultam auditoria central.
5. **Código potencialmente morto**: classes registradas sem consumo Lua explícito devem ser auditadas por telemetria/grep de uso.

## Hardening recomendado
- Travar classes críticas com proxies readonly em produção.
- Validar nomes de eventos aceitáveis em `__newindex`.
- Inserir lint para detectar escrita acidental em métodos globais.
