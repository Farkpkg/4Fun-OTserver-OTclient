# Distinção entre BOT nativo OTClient e RTC Helper (Complete Custom Client)

## Resumo
Este repositório contém duas linhas conceituais diferentes:

1. **BOT nativo OTClient** (referenciado como `game_bot` em alguns pontos do código base).
2. **RTC Helper** (módulo portado do `COMPLETE_CUSTOM_CLIENT`, agora nomeado como `game_rtc_helper` no OTClient para evitar colisão semântica).

Eles **não são o mesmo sistema**.

## Evidências de BOT nativo no OTClient
- `otclient/modules/game_interface/gameinterface.lua` contém checagem condicional para `modules.game_bot`.
- `otclient/modules/game_actionbar/logics/ActionButtonLogic.lua` contém checagem condicional para `modules.game_bot`.
- `otclient/src/framework/ui/uiwidget.cpp` possui referência de caminho `game_bot/functions/ui`.

Esses pontos indicam uma integração esperada com um bot nativo, independente do RTC Helper.

## Evidências do RTC Helper portado
- Módulo portado em `otclient/modules/game_helper/*`.
- Nome do módulo OTClient ajustado para `game_rtc_helper` em `helper.otmod`.
- Loader da interface ajustado para `game_rtc_helper` em `otclient/modules/game_interface/interface.otmod`.
- Callbacks OTUI ajustados para `modules.game_rtc_helper`.

## Decisão aplicada para evitar confusão
- Mantido o código do RTC Helper em pasta dedicada (`game_helper`), porém com **nome lógico do módulo `game_rtc_helper`**.
- Evita colisão de namespace e de interpretação com `modules.game_bot`.
- Mantém explícito que RTC Helper e BOT nativo OTClient são sistemas distintos.

## Observação de arquitetura
Se o BOT nativo (`game_bot`) for adicionado/ativado neste workspace no futuro, ele pode coexistir com `game_rtc_helper`, desde que as integrações de UI/hotkeys permaneçam separadas.
