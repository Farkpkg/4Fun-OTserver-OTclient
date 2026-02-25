# 06_RISCOS

- Uso de lookType inválido pode causar visual incorreto (mitigado por lista configurável).
- Troca constante pode gerar ruído visual em áreas com muitos jogadores.
- Se o jogador relogar durante uso, o loop depende da checagem `Player(playerId)` para cessar corretamente.
