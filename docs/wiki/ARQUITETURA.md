[Wiki](README.md) > Mapa de Arquitetura

# Mapa de arquitetura (conceitual)

## Visão macro
O projeto é composto por três camadas principais: **Cliente**, **Protocolo** e **Servidor**, com dados e scripts como pontos de extensão.

```
+-------------------+        +--------------------+        +-------------------+
|      Cliente      | <----> |     Protocolo      | <----> |      Servidor     |
| (OTClient + UI)   |        | (Login/Status/Game)|        | (CrystalServer)   |
+-------------------+        +--------------------+        +-------------------+
        |                                                       |
        |                                                       |
        v                                                       v
  Assets/UI/Mods                                         Scripts/Data/DB
```

## Camadas
- **Cliente**: renderização, UI e input (`otclient/src`, `otclient/modules`, `otclient/data`).
- **Protocolo**: troca de mensagens entre cliente e servidor (`protocolgame`, `protocollogin`, `protocolstatus`).
- **Servidor**: regras de jogo, estado persistente, scripts e banco (`crystalserver/src`, `crystalserver/data`).

## Fluxos principais
- **Login**: cliente → `ProtocolLogin` → validação no servidor → resposta de login.
- **Jogo**: cliente ↔ `ProtocolGame` ↔ núcleo do jogo (mapas, criaturas, itens).
- **Eventos/scripts**: servidor aciona scripts Lua conforme eventos/ações.

## Pontos de acoplamento forte
- **OpCodes e versões de protocolo**: mudanças exigem sincronização cliente ↔ servidor.
- **Estrutura de dados de itens/criaturas**: mudanças nos dados impactam rendering e gameplay.

## Pontos de desacoplamento
- **Scripts Lua**: permitem extensões sem recompilar.
- **Módulos do cliente**: UI e features podem ser adicionadas/removidas via módulos.
