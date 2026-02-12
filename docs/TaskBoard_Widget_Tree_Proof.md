# TaskBoard Widget Tree Proof

## Sources
- Custom OTUI: `COMPLETE_CUSTOM_CLIENT/modules/mods/game_battlepass/battlepass.otui`
- TaskBoard OTUI: `otclient/modules/game_taskboard/taskboard.otui`

## Custom — Complete OTUI Tree (depth/order/classes/properties)
```text
ConfirmReward < NewHeadlessWindow  [L1]
  · anchors.centerIn: parent
  · size: 455 245
  UIWidget  [L4]
    · size: 145 56
    · anchors.top: parent.top
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-top: -33
  Panel  [L11]
    · anchors.fill: parent
    · margin: 15 13 17 13
    TextEdit  [L15]
      · anchors.top: parent.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: separator.top
      · margin-top: 10
      · margin-bottom: 10
    VerticalScrollBar  [L31]
      · anchors.top: prev.top
      · anchors.bottom: prev.bottom
      · anchors.right: prev.right
      · margin: 1 1 1 0
    HorizontalSeparator  [L40]
      · anchors.bottom: next.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-bottom: 10
    Button  [L46]
      · anchors.bottom: parent.bottom
      · anchors.right: parent.right
      · size: 43 20
    Button  [L53]
      · anchors.bottom: parent.bottom
      · anchors.right: prev.left
      · margin-right: 5
      · size: 43 20
RewardInfoSlot < UIWidget  [L61]
  · size: 66 66
  BigItem  [L82]
    · size: 64 64
    · anchors.horizontalCenter: parent.horizontalCenter
    · anchors.verticalCenter: parent.verticalCenter
    Label  [L95]
      · anchors.bottom: parent.bottom
      · anchors.right: parent.right
      · margin-bottom: 2
      · margin-right: 2
  UICreature  [L105]
    · size: 64 64
    · anchors.horizontalCenter: parent.horizontalCenter
    · anchors.verticalCenter: parent.verticalCenter
  UIWidget  [L114]
    · size: 64 64
    · anchors.horizontalCenter: parent.horizontalCenter
    · anchors.verticalCenter: parent.verticalCenter
SelectRewardWindow < NewHeadlessWindow  [L124]
  · anchors.horizontalCenter: parent.horizontalCenter
  · size: 500 255
  UIWidget  [L129]
    · size: 145 56
    · anchors.top: parent.top
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-top: -33
  Panel  [L136]
    · anchors.fill: parent
    · margin: 15 13 17 13
    Label  [L140]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 15
    Label  [L151]
      · anchors.top: rewardLabel.bottom
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 10
    UIButton  [L163]
      · size: 20 20
      · anchors.top: next.top
      · anchors.right: next.left
      · margin-top: 30
      · margin-right: 10
    TextList  [L178]
      · anchors.top: infoLabel.bottom
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 10
      · margin-bottom: 10
      · layout:
      · type: grid
      · cell-size: 66 66
      for i = 1, 30 do  [L197]
        local slot = g_ui.createWidget('RewardInfoSlot', self)  [L198]
        end  [L201]
    UIButton  [L202]
      · size: 20 20
      · anchors.top: prev.top
      · anchors.left: prev.right
      · margin-top: 30
      · margin-left: 10
    HorizontalScrollBar  [L217]
      · anchors.bottom: rewardsInfoPanel.bottom
      · anchors.right: rewardsInfoPanel.right
      · anchors.left: rewardsInfoPanel.left
      · margin: 0 1 1 2
    UIButton  [L227]
      · size: 20 20
      · anchors.top: next.top
      · anchors.right: next.left
      · margin-top: 30
      · margin-right: 10
    TextList  [L242]
      · anchors.top: rewardsInfoPanel.bottom
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 10
      · margin-bottom: 10
      · layout:
      · type: grid
      · cell-size: 66 66
      RewardInfoSlot  [L259]
      RewardInfoSlot  [L262]
      RewardInfoSlot  [L265]
      RewardInfoSlot  [L268]
    UIButton  [L272]
      · size: 20 20
      · anchors.top: prev.top
      · anchors.left: prev.right
      · margin-top: 30
      · margin-left: 10
    HorizontalSeparator  [L287]
      · anchors.bottom: next.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-bottom: 10
    Button  [L293]
      · anchors.bottom: parent.bottom
      · anchors.right: parent.right
      · size: 43 20
    Button  [L299]
      · size: 63 20
      · anchors.bottom: parent.bottom
      · anchors.right: prev.left
      · margin-right: 5
    UIWidget  [L308]
      · size: 65 22
      · anchors.top: prev.top
      · anchors.left: prev.left
      · margin-left: -1
      · margin-top: -1
PlaceHolder < UIWidget  [L318]
  · size: 16380 384
  UICreature  [L322]
    · size: 64 64
    · anchors.top: parent.top
    · anchors.left: parent.left
    · margin-left: 165
    · margin-top: 175
MapFragment < UIWidget  [L331]
  · size: 384 384
  · anchors.top: parent.top
  · anchors.left: parent.left
DailyMissionWidget < UIWidget  [L336]
  · size: 100 154
  Panel  [L341]
    · size: 86 80
    · anchors.top: parent.top
    · anchors.left: parent.left
    · margin-top: 9
    · margin-left: 9
    UIWidget  [L348]
      · size: 40 40
      · anchors.horizontalCenter: parent.horizontalCenter
      · anchors.verticalCenter: parent.verticalCenter
      · margin-left: -2
    UIWidget  [L355]
      · size: 12 12
      · anchors.top: parent.top
      · anchors.right: parent.right
      · margin-top: 5
      · margin-right: 7
    Label  [L364]
      · anchors.bottom: parent.bottom
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-left: -4
  Label  [L373]
    · size: 92 30
    · anchors.top: prev.bottom
    · anchors.left: parent.left
    · margin-top: 10
    · margin-left: 4
  Panel  [L385]
    · size: 85 15
    · anchors.bottom: parent.bottom
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-bottom: 7
    ProgressBarSD  [L391]
      · anchors.fill: parent
      · margin: 1 1 1 1
    Label  [L398]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: -1
  UIWidget  [L407]
    · size: 13 13
    · anchors.bottom: parent.bottom
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-bottom: 9
  UIWidget  [L415]
    · anchors.fill: parent
  UIWidget  [L420]
    · size: 14 14
    · anchors.top: parent.top
    · anchors.left: parent.left
    · margin-top: 12
    · margin-left: 10
  UIWidget  [L436]
    · size: 36 36
    · anchors.top: parent.top
    · anchors.left: parent.left
    · margin: 2
MissionWidget < UIWidget  [L446]
  · size: 104 154
  Panel  [L451]
    · size: 86 80
    · anchors.top: parent.top
    · anchors.left: parent.left
    · margin-top: 9
    · margin-left: 9
    UIWidget  [L458]
      · size: 40 40
      · anchors.horizontalCenter: parent.horizontalCenter
      · anchors.verticalCenter: parent.verticalCenter
    UIWidget  [L464]
      · size: 12 12
      · anchors.top: parent.top
      · anchors.right: parent.right
      · margin-top: 5
      · margin-right: 5
    Label  [L473]
      · anchors.bottom: parent.bottom
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-left: -1
  Label  [L482]
    · size: 96 30
    · anchors.top: prev.bottom
    · anchors.left: parent.left
    · margin-top: 10
    · margin-left: 4
  Panel  [L494]
    · size: 85 15
    · anchors.bottom: parent.bottom
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-bottom: 7
    ProgressBarSD  [L500]
      · anchors.fill: parent
      · margin: 1 1 1 1
    Label  [L507]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: -1
  UIWidget  [L516]
    · size: 13 13
    · anchors.bottom: parent.bottom
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-bottom: 9
  UIWidget  [L524]
    · anchors.fill: parent
  UIWidget  [L529]
    · size: 20 20
    · anchors.top: parent.top
    · anchors.left: parent.left
    · margin: 2
  UIWidget  [L537]
    · size: 36 36
    · anchors.top: parent.top
    · anchors.left: parent.left
    · margin: 2
MissionPanel < Panel  [L546]
  · anchors.fill: parent
  Panel  [L548]
    · size: 220 235
    · anchors.top: parent.top
    · anchors.left: parent.left
    Panel  [L555]
      · anchors.fill: parent
      · margin: 5
      Panel  [L559]
        · size: 210 225
        · anchors.top: parent.top
        · anchors.left: parent.left
        UIWidget  [L566]
          · anchors.fill: parent
          · margin: 1 1 1 1
  Panel  [L572]
    · size: 220 225
    · anchors.top: prev.bottom
    · anchors.left: parent.left
    · margin-top: 7
    Label  [L580]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 2
    Panel  [L589]
      · size: 210 164
      · anchors.top: parent.top
      · anchors.left: parent.left
      · margin-top: 24
      · margin-left: 5
      · layout:
      · type: grid
      · cell-size: 100 154
      DailyMissionWidget  [L606]
      DailyMissionWidget  [L610]
    UIWidget  [L614]
      · anchors.bottom: parent.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-bottom: 9
      · margin-left: 5
      · margin-right: 5
      ProgressBarSD  [L625]
        · anchors.fill: parent
        · margin: 1 1 1 1
      Label  [L631]
        · anchors.verticalCenter: parent.verticalCenter
        · anchors.horizontalCenter: parent.horizontalCenter
      UIWidget  [L639]
        · size: 10 15
        · anchors.top: prev.top
        · anchors.left: prev.right
        · margin-left: 5
  Panel  [L647]
    · anchors.top: parent.top
    · anchors.left: prev.right
    · anchors.right: parent.right
    · margin-left: 10
    Label  [L656]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 2
    Panel  [L665]
      · anchors.top: parent.top
      · anchors.fill: parent
      · margin: 18 5 5 5
      UIWidget  [L670]
        · size: 90 85
        · anchors.top: parent.top
        · anchors.left: parent.left
        · margin-top: 8
        · margin-left: 5
        UIWidget  [L679]
          · size: 81 75
          · anchors.centerIn: parent
          Label  [L684]
            · anchors.bottom: parent.bottom
            · anchors.left: parent.left
            · anchors.right: parent.right
            · margin-bottom: 4
            · margin-left: -3
      Label  [L696]
        · anchors.top: parent.top
        · anchors.left: playerLevelBg.right
        · margin-top: 7
        · margin-left: 45
      Label  [L706]
        · anchors.top: prev.bottom
        · anchors.left: playerLevelBg.right
        · margin-top: 5
        · margin-left: 95
      HorizontalSeparator  [L718]
        · anchors.top: battlePassDesc.bottom
        · anchors.left: playerLevelBg.right
        · anchors.right: parent.right
        · margin-top: 24
        · margin-left: 8
        · margin-right: 4
      Label  [L726]
        · anchors.bottom: progressBarBg.top
        · anchors.horizontalCenter: progressBarBg.horizontalCenter
        · margin-bottom: 5
      UIWidget  [L735]
        · size: 195 20
        · anchors.bottom: parent.bottom
        · anchors.left: playerLevelBg.right
        · margin-bottom: 4
        · margin-left: 8
        ProgressBarSD  [L744]
          · anchors.fill: parent
          · margin: 1 1 1 1
        Label  [L750]
          · anchors.verticalCenter: parent.verticalCenter
          · anchors.horizontalCenter: parent.horizontalCenter
          · margin-left: -5
      VerticalSeparator  [L759]
        · anchors.top: battlePassDescSep.bottom
        · anchors.left: progressBarBg.right
        · anchors.bottom: parent.bottom
        · margin-top: 7
        · margin-left: 17
        · margin-bottom: 4
      Label  [L767]
        · anchors.bottom: seasonTimeBg.top
        · anchors.horizontalCenter: seasonTimeBg.horizontalCenter
        · margin-bottom: 5
      UIWidget  [L776]
        · size: 195 20
        · anchors.bottom: parent.bottom
        · anchors.right: parent.right
        · margin-bottom: 4
        · margin-right: 4
        ProgressBarSD  [L785]
          · anchors.fill: parent
          · margin: 1 1 1 1
        Label  [L791]
          · anchors.verticalCenter: parent.verticalCenter
          · anchors.horizontalCenter: parent.horizontalCenter
          · margin-left: -5
          · margin-top: 1
        UIWidget  [L801]
          · size: 10 15
          · anchors.top: prev.top
          · anchors.left: prev.right
          · margin-left: 5
  ScrollablePanel  [L808]
    · anchors.top: prev.bottom
    · anchors.left: prev.left
    · anchors.right: parent.right
    · anchors.bottom: parent.bottom
    · margin-top: 10
    · layout:
    · type: grid
    · cell-size: 104 154
    MissionWidget  [L826]
    MissionWidget  [L827]
    MissionWidget  [L828]
    MissionWidget  [L829]
    MissionWidget  [L830]
    MissionWidget  [L831]
    MissionWidget  [L832]
    MissionWidget  [L833]
    MissionWidget  [L834]
    MissionWidget  [L835]
    MissionWidget  [L836]
    MissionWidget  [L837]
    MissionWidget  [L838]
    MissionWidget  [L839]
    MissionWidget  [L840]
    MissionWidget  [L841]
    MissionWidget  [L842]
    MissionWidget  [L843]
    MissionWidget  [L844]
    MissionWidget  [L845]
    MissionWidget  [L846]
    MissionWidget  [L847]
    MissionWidget  [L848]
    MissionWidget  [L849]
    MissionWidget  [L850]
    MissionWidget  [L851]
  HorizontalScrollBar  [L854]
    · anchors.bottom: prev.bottom
    · anchors.right: prev.right
    · anchors.left: prev.left
    · margin: 0 1 1 2
BlockedRewardWidget < Panel  [L864]
  · size: 120 71
  · anchors.top: parent.top
  · anchors.left: parent.left
  UIWidget  [L868]
    · size: 120 71
    · anchors.top: parent.top
    · anchors.left: parent.left
    Label  [L882]
      · anchors.bottom: parent.bottom
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-bottom: 22
      · margin-left: 2
  UIWidget  [L892]
    · size: 29 31
    · anchors.top: parent.top
    · anchors.horizontalCenter: parent.horizontalCenter
RewardWidget < Panel  [L901]
  · size: 120 71
  · anchors.top: parent.top
  · anchors.left: parent.left
  UIWidget  [L905]
    · size: 120 71
    · anchors.top: parent.top
    · anchors.left: parent.left
    Label  [L917]
      · anchors.bottom: parent.bottom
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-bottom: 22
      · margin-left: 2
  UIWidget  [L927]
    · size: 29 31
    · anchors.top: parent.top
    · anchors.horizontalCenter: parent.horizontalCenter
ProgressPanel < Panel  [L936]
  · anchors.fill: parent
  ScrollablePanel  [L938]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    Panel  [L950]
      · size: 18045 384
      · anchors.top: parent.top
      · anchors.left: parent.left
      for i = 0, 46 do  [L956]
        local widget = g_ui.createWidget('MapFragment', self)  [L957]
        end  [L960]
    UICreature  [L962]
      · size: 64 64
      · anchors.top: parent.top
      · anchors.left: parent.left
      · margin-left: 165
      · margin-top: 165
  HorizontalScrollBar  [L973]
    · anchors.bottom: prev.bottom
    · anchors.right: prev.right
    · anchors.left: prev.left
    · margin: 0 1 1 1
// MAIN WINDOW  [L985]
NewHeadlessWindow  [L986]
  · anchors.horizontalCenter: parent.horizontalCenter
  · size: 795 595
  UIWidget  [L991]
    · size: 145 56
    · anchors.top: parent.top
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-top: -33
  Panel  [L998]
    · anchors.fill: parent
    · margin: 15 13 17 13
    Panel  [L1002]
      · anchors.top: parent.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-top: 12
      Button  [L1011]
        · anchors.top: parent.top
        · anchors.left: parent.left
        · size: 384 34
        · margin-left: 1
        · margin-top: 1
      Button  [L1027]
        · anchors.top: parent.top
        · anchors.left: prev.right
        · size: 383 34
        · margin-left: 1
        · margin-top: 1
    Panel  [L1044]
      · anchors.top: optionsTabBar.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: separator.top
      · margin-top: 12
      · margin-bottom: 8
      MissionPanel  [L1052]
      ProgressPanel  [L1055]
    HorizontalSeparator  [L1059]
      · anchors.bottom: next.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-bottom: 10
    Button  [L1065]
      · anchors.bottom: parent.bottom
      · anchors.right: parent.right
      · size: 43 20
    Button  [L1073]
      · size: 80 20
      · anchors.bottom: parent.bottom
      · anchors.right: prev.left
      · margin-right: 9
    Button  [L1084]
      · size: 130 20
      · anchors.bottom: parent.bottom
      · anchors.right: prev.left
      · margin-right: 9
      UIWidget  [L1094]
        · size: 16 16
        · anchors.top: parent.top
        · anchors.left: parent.left
        · margin-left: -10
        · margin-top: -10
    UIWidget  [L1103]
      · size: 133 22
      · anchors.top: prev.top
      · anchors.left: prev.left
      · margin-left: -1
      · margin-top: -1
    Panel  [L1113]
      · size: 130 20
      · anchors.bottom: parent.bottom
      · anchors.left: parent.left
      Panel  [L1120]
        · anchors.right: parent.right
        · anchors.top: parent.top
        · margin-top: 6
        · margin-right: 3
      UIWidget  [L1126]
        · anchors.top: parent.top
        · anchors.right: prev.left
        · margin-right: 5
        · margin-top: 3
```

## TaskBoard — Complete OTUI Tree (depth/order/classes/properties)
```text
TaskBoardMenuButton < UIButton  [L1]
  · size: 120 24
TaskBoardDailyMissionWidget < Panel  [L7]
  Label  [L12]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    · margin: 4
  RectangleProgressBar  [L20]
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: missionProgressText.top
    · margin-left: 6
    · margin-right: 6
    · margin-bottom: 2
  Label  [L32]
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: parent.bottom
    · margin-bottom: 4
TaskBoardTrackRewardSlot < Panel  [L41]
  Label  [L47]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    · margin-top: 2
  Label  [L56]
    · anchors.top: levelLabel.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · margin-top: 2
  Button  [L65]
    · anchors.bottom: parent.bottom
    · anchors.horizontalCenter: parent.horizontalCenter
    · margin-bottom: 2
TaskBoardMissionPanel < Panel  [L74]
  Panel  [L77]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    Label  [L86]
      · anchors.top: parent.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-top: 4
    Panel  [L95]
      · anchors.top: dailyTitle.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: parent.bottom
      · margin: 6
      · layout:
      · type: verticalBox
      · spacing: 4
  Panel  [L106]
    · anchors.top: dailyBg.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · margin-top: 6
    Label  [L116]
      · anchors.left: parent.left
      · anchors.verticalCenter: parent.verticalCenter
      · margin-left: 10
    RectangleProgressBar  [L123]
      · anchors.left: playerLevel.right
      · anchors.right: currentlyLevelText.left
      · anchors.verticalCenter: parent.verticalCenter
      · margin-left: 8
      · margin-right: 8
    Label  [L134]
      · anchors.right: parent.right
      · anchors.verticalCenter: parent.verticalCenter
      · margin-right: 10
  Panel  [L141]
    · anchors.top: playerProgressPanel.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: parent.bottom
    · margin-top: 6
    Panel  [L151]
      · anchors.top: parent.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      ComboBox  [L158]
        · anchors.left: parent.left
        · anchors.verticalCenter: parent.verticalCenter
      Button  [L164]
        · anchors.left: difficultyDropdown.right
        · anchors.verticalCenter: parent.verticalCenter
        · margin-left: 6
      Button  [L172]
        · anchors.left: preferredListButton.right
        · anchors.verticalCenter: parent.verticalCenter
        · margin-left: 6
      Button  [L180]
        · anchors.left: rerollButton.right
        · anchors.verticalCenter: parent.verticalCenter
        · margin-left: 6
    Panel  [L188]
      · anchors.top: bountyToolbar.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: bountyCardsContainer.top
      · margin-top: 6
      · margin-bottom: 6
      Label  [L199]
        · anchors.centerIn: parent
    Panel  [L204]
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: weeklyContainer.top
      · margin-bottom: 6
      · layout:
      · type: horizontalBox
      · spacing: 8
    Panel  [L215]
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: parent.bottom
      Panel  [L222]
        · anchors.top: parent.top
        · anchors.left: parent.left
        · anchors.bottom: parent.bottom
        Label  [L231]
          · anchors.top: parent.top
          · anchors.left: parent.left
          · anchors.right: parent.right
          · margin-top: 3
        ScrollablePanel  [L240]
          · anchors.top: weeklyKillTitle.bottom
          · anchors.left: parent.left
          · anchors.right: parent.right
          · anchors.bottom: parent.bottom
          · margin: 4
          · layout:
          · type: grid
          · cell-size: 150 84
      Panel  [L252]
        · anchors.top: parent.top
        · anchors.right: parent.right
        · anchors.bottom: parent.bottom
        Label  [L261]
          · anchors.top: parent.top
          · anchors.left: parent.left
          · anchors.right: parent.right
          · margin-top: 3
        ScrollablePanel  [L270]
          · anchors.top: weeklyDeliveryTitle.bottom
          · anchors.left: parent.left
          · anchors.right: parent.right
          · anchors.bottom: parent.bottom
          · margin: 4
          · layout:
          · type: grid
          · cell-size: 150 84
TaskBoardProgressPanel < Panel  [L282]
  Panel  [L286]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    Label  [L295]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 6
    TaskBoardProgressTrack  [L302]
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: parent.bottom
  Label  [L309]
    · anchors.top: progressHeader.bottom
    · anchors.left: parent.left
    · margin-top: 6
  ScrollablePanel  [L316]
    · anchors.top: freeTrackLabel.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · margin-top: 2
    · layout:
    · type: horizontalBox
    · spacing: 6
  Label  [L327]
    · anchors.top: freeTrack.bottom
    · anchors.left: parent.left
    · margin-top: 6
  ScrollablePanel  [L334]
    · anchors.top: premiumTrackLabel.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: shopGrid.top
    · margin-top: 2
    · margin-bottom: 6
    · layout:
    · type: horizontalBox
    · spacing: 6
  ScrollablePanel  [L346]
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: parent.bottom
    · layout:
    · type: grid
    · cell-size: 310 124
MainWindow  [L357]
  · size: 980 620
  Panel  [L364]
    · anchors.fill: parent
    · margin: 8
    Panel  [L369]
      · anchors.top: parent.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      TaskBoardMenuButton  [L376]
        · anchors.left: parent.left
        · anchors.verticalCenter: parent.verticalCenter
      TaskBoardMenuButton  [L382]
        · anchors.left: challengesMenu.right
        · anchors.verticalCenter: parent.verticalCenter
        · margin-left: 8
    Panel  [L389]
      · anchors.top: optionsTabBar.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: closeButton.top
      · margin-top: 8
      · margin-bottom: 8
      TaskBoardMissionPanel  [L398]
      TaskBoardProgressPanel  [L399]
    Button  [L401]
      · anchors.right: parent.right
      · anchors.bottom: parent.bottom
```

## Custom missionPanel subtree
```text
MissionPanel < Panel  [L546]
  · anchors.fill: parent
  Panel  [L548]
    · size: 220 235
    · anchors.top: parent.top
    · anchors.left: parent.left
    Panel  [L555]
      · anchors.fill: parent
      · margin: 5
      Panel  [L559]
        · size: 210 225
        · anchors.top: parent.top
        · anchors.left: parent.left
        UIWidget  [L566]
          · anchors.fill: parent
          · margin: 1 1 1 1
  Panel  [L572]
    · size: 220 225
    · anchors.top: prev.bottom
    · anchors.left: parent.left
    · margin-top: 7
    Label  [L580]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 2
    Panel  [L589]
      · size: 210 164
      · anchors.top: parent.top
      · anchors.left: parent.left
      · margin-top: 24
      · margin-left: 5
      · layout:
      · type: grid
      · cell-size: 100 154
      DailyMissionWidget  [L606]
      DailyMissionWidget  [L610]
    UIWidget  [L614]
      · anchors.bottom: parent.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-bottom: 9
      · margin-left: 5
      · margin-right: 5
      ProgressBarSD  [L625]
        · anchors.fill: parent
        · margin: 1 1 1 1
      Label  [L631]
        · anchors.verticalCenter: parent.verticalCenter
        · anchors.horizontalCenter: parent.horizontalCenter
      UIWidget  [L639]
        · size: 10 15
        · anchors.top: prev.top
        · anchors.left: prev.right
        · margin-left: 5
  Panel  [L647]
    · anchors.top: parent.top
    · anchors.left: prev.right
    · anchors.right: parent.right
    · margin-left: 10
    Label  [L656]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 2
    Panel  [L665]
      · anchors.top: parent.top
      · anchors.fill: parent
      · margin: 18 5 5 5
      UIWidget  [L670]
        · size: 90 85
        · anchors.top: parent.top
        · anchors.left: parent.left
        · margin-top: 8
        · margin-left: 5
        UIWidget  [L679]
          · size: 81 75
          · anchors.centerIn: parent
          Label  [L684]
            · anchors.bottom: parent.bottom
            · anchors.left: parent.left
            · anchors.right: parent.right
            · margin-bottom: 4
            · margin-left: -3
      Label  [L696]
        · anchors.top: parent.top
        · anchors.left: playerLevelBg.right
        · margin-top: 7
        · margin-left: 45
      Label  [L706]
        · anchors.top: prev.bottom
        · anchors.left: playerLevelBg.right
        · margin-top: 5
        · margin-left: 95
      HorizontalSeparator  [L718]
        · anchors.top: battlePassDesc.bottom
        · anchors.left: playerLevelBg.right
        · anchors.right: parent.right
        · margin-top: 24
        · margin-left: 8
        · margin-right: 4
      Label  [L726]
        · anchors.bottom: progressBarBg.top
        · anchors.horizontalCenter: progressBarBg.horizontalCenter
        · margin-bottom: 5
      UIWidget  [L735]
        · size: 195 20
        · anchors.bottom: parent.bottom
        · anchors.left: playerLevelBg.right
        · margin-bottom: 4
        · margin-left: 8
        ProgressBarSD  [L744]
          · anchors.fill: parent
          · margin: 1 1 1 1
        Label  [L750]
          · anchors.verticalCenter: parent.verticalCenter
          · anchors.horizontalCenter: parent.horizontalCenter
          · margin-left: -5
      VerticalSeparator  [L759]
        · anchors.top: battlePassDescSep.bottom
        · anchors.left: progressBarBg.right
        · anchors.bottom: parent.bottom
        · margin-top: 7
        · margin-left: 17
        · margin-bottom: 4
      Label  [L767]
        · anchors.bottom: seasonTimeBg.top
        · anchors.horizontalCenter: seasonTimeBg.horizontalCenter
        · margin-bottom: 5
      UIWidget  [L776]
        · size: 195 20
        · anchors.bottom: parent.bottom
        · anchors.right: parent.right
        · margin-bottom: 4
        · margin-right: 4
        ProgressBarSD  [L785]
          · anchors.fill: parent
          · margin: 1 1 1 1
        Label  [L791]
          · anchors.verticalCenter: parent.verticalCenter
          · anchors.horizontalCenter: parent.horizontalCenter
          · margin-left: -5
          · margin-top: 1
        UIWidget  [L801]
          · size: 10 15
          · anchors.top: prev.top
          · anchors.left: prev.right
          · margin-left: 5
  ScrollablePanel  [L808]
    · anchors.top: prev.bottom
    · anchors.left: prev.left
    · anchors.right: parent.right
    · anchors.bottom: parent.bottom
    · margin-top: 10
    · layout:
    · type: grid
    · cell-size: 104 154
    MissionWidget  [L826]
    MissionWidget  [L827]
    MissionWidget  [L828]
    MissionWidget  [L829]
    MissionWidget  [L830]
    MissionWidget  [L831]
    MissionWidget  [L832]
    MissionWidget  [L833]
    MissionWidget  [L834]
    MissionWidget  [L835]
    MissionWidget  [L836]
    MissionWidget  [L837]
    MissionWidget  [L838]
    MissionWidget  [L839]
    MissionWidget  [L840]
    MissionWidget  [L841]
    MissionWidget  [L842]
    MissionWidget  [L843]
    MissionWidget  [L844]
    MissionWidget  [L845]
    MissionWidget  [L846]
    MissionWidget  [L847]
    MissionWidget  [L848]
    MissionWidget  [L849]
    MissionWidget  [L850]
    MissionWidget  [L851]
  HorizontalScrollBar  [L854]
    · anchors.bottom: prev.bottom
    · anchors.right: prev.right
    · anchors.left: prev.left
    · margin: 0 1 1 2
```

## TaskBoard missionPanel subtree
```text
TaskBoardMissionPanel < Panel  [L74]
  Panel  [L77]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    Label  [L86]
      · anchors.top: parent.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      · margin-top: 4
    Panel  [L95]
      · anchors.top: dailyTitle.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: parent.bottom
      · margin: 6
      · layout:
      · type: verticalBox
      · spacing: 4
  Panel  [L106]
    · anchors.top: dailyBg.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · margin-top: 6
    Label  [L116]
      · anchors.left: parent.left
      · anchors.verticalCenter: parent.verticalCenter
      · margin-left: 10
    RectangleProgressBar  [L123]
      · anchors.left: playerLevel.right
      · anchors.right: currentlyLevelText.left
      · anchors.verticalCenter: parent.verticalCenter
      · margin-left: 8
      · margin-right: 8
    Label  [L134]
      · anchors.right: parent.right
      · anchors.verticalCenter: parent.verticalCenter
      · margin-right: 10
  Panel  [L141]
    · anchors.top: playerProgressPanel.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: parent.bottom
    · margin-top: 6
    Panel  [L151]
      · anchors.top: parent.top
      · anchors.left: parent.left
      · anchors.right: parent.right
      ComboBox  [L158]
        · anchors.left: parent.left
        · anchors.verticalCenter: parent.verticalCenter
      Button  [L164]
        · anchors.left: difficultyDropdown.right
        · anchors.verticalCenter: parent.verticalCenter
        · margin-left: 6
      Button  [L172]
        · anchors.left: preferredListButton.right
        · anchors.verticalCenter: parent.verticalCenter
        · margin-left: 6
      Button  [L180]
        · anchors.left: rerollButton.right
        · anchors.verticalCenter: parent.verticalCenter
        · margin-left: 6
    Panel  [L188]
      · anchors.top: bountyToolbar.bottom
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: bountyCardsContainer.top
      · margin-top: 6
      · margin-bottom: 6
      Label  [L199]
        · anchors.centerIn: parent
    Panel  [L204]
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: weeklyContainer.top
      · margin-bottom: 6
      · layout:
      · type: horizontalBox
      · spacing: 8
    Panel  [L215]
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: parent.bottom
      Panel  [L222]
        · anchors.top: parent.top
        · anchors.left: parent.left
        · anchors.bottom: parent.bottom
        Label  [L231]
          · anchors.top: parent.top
          · anchors.left: parent.left
          · anchors.right: parent.right
          · margin-top: 3
        ScrollablePanel  [L240]
          · anchors.top: weeklyKillTitle.bottom
          · anchors.left: parent.left
          · anchors.right: parent.right
          · anchors.bottom: parent.bottom
          · margin: 4
          · layout:
          · type: grid
          · cell-size: 150 84
      Panel  [L252]
        · anchors.top: parent.top
        · anchors.right: parent.right
        · anchors.bottom: parent.bottom
        Label  [L261]
          · anchors.top: parent.top
          · anchors.left: parent.left
          · anchors.right: parent.right
          · margin-top: 3
        ScrollablePanel  [L270]
          · anchors.top: weeklyDeliveryTitle.bottom
          · anchors.left: parent.left
          · anchors.right: parent.right
          · anchors.bottom: parent.bottom
          · margin: 4
          · layout:
          · type: grid
          · cell-size: 150 84
```

## Custom progressPanel subtree
```text
ProgressPanel < Panel  [L936]
  · anchors.fill: parent
  ScrollablePanel  [L938]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    Panel  [L950]
      · size: 18045 384
      · anchors.top: parent.top
      · anchors.left: parent.left
      for i = 0, 46 do  [L956]
        local widget = g_ui.createWidget('MapFragment', self)  [L957]
        end  [L960]
    UICreature  [L962]
      · size: 64 64
      · anchors.top: parent.top
      · anchors.left: parent.left
      · margin-left: 165
      · margin-top: 165
  HorizontalScrollBar  [L973]
    · anchors.bottom: prev.bottom
    · anchors.right: prev.right
    · anchors.left: prev.left
    · margin: 0 1 1 1
```

## TaskBoard progressPanel subtree
```text
TaskBoardProgressPanel < Panel  [L282]
  Panel  [L286]
    · anchors.top: parent.top
    · anchors.left: parent.left
    · anchors.right: parent.right
    Label  [L295]
      · anchors.top: parent.top
      · anchors.horizontalCenter: parent.horizontalCenter
      · margin-top: 6
    TaskBoardProgressTrack  [L302]
      · anchors.left: parent.left
      · anchors.right: parent.right
      · anchors.bottom: parent.bottom
  Label  [L309]
    · anchors.top: progressHeader.bottom
    · anchors.left: parent.left
    · margin-top: 6
  ScrollablePanel  [L316]
    · anchors.top: freeTrackLabel.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · margin-top: 2
    · layout:
    · type: horizontalBox
    · spacing: 6
  Label  [L327]
    · anchors.top: freeTrack.bottom
    · anchors.left: parent.left
    · margin-top: 6
  ScrollablePanel  [L334]
    · anchors.top: premiumTrackLabel.bottom
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: shopGrid.top
    · margin-top: 2
    · margin-bottom: 6
    · layout:
    · type: horizontalBox
    · spacing: 6
  ScrollablePanel  [L346]
    · anchors.left: parent.left
    · anchors.right: parent.right
    · anchors.bottom: parent.bottom
    · layout:
    · type: grid
    · cell-size: 310 124
```

## Structural divergences (path-based, no interpretation)
### missionPanel paths only in Custom
```text
MissionPanel
MissionPanel/HorizontalScrollBar
MissionPanel/Panel
MissionPanel/Panel/Label
MissionPanel/Panel/Panel
MissionPanel/Panel/Panel/DailyMissionWidget
MissionPanel/Panel/Panel/HorizontalSeparator
MissionPanel/Panel/Panel/Label
MissionPanel/Panel/Panel/Panel
MissionPanel/Panel/Panel/Panel/UIWidget
MissionPanel/Panel/Panel/UIWidget
MissionPanel/Panel/Panel/UIWidget/Label
MissionPanel/Panel/Panel/UIWidget/ProgressBarSD
MissionPanel/Panel/Panel/UIWidget/UIWidget
MissionPanel/Panel/Panel/UIWidget/UIWidget/Label
MissionPanel/Panel/Panel/VerticalSeparator
MissionPanel/Panel/UIWidget
MissionPanel/Panel/UIWidget/Label
MissionPanel/Panel/UIWidget/ProgressBarSD
MissionPanel/Panel/UIWidget/UIWidget
MissionPanel/ScrollablePanel
MissionPanel/ScrollablePanel/MissionWidget
```
### missionPanel paths only in TaskBoard
```text
TaskBoardMissionPanel
TaskBoardMissionPanel/Panel
TaskBoardMissionPanel/Panel/Label
TaskBoardMissionPanel/Panel/Panel
TaskBoardMissionPanel/Panel/Panel/Button
TaskBoardMissionPanel/Panel/Panel/ComboBox
TaskBoardMissionPanel/Panel/Panel/Label
TaskBoardMissionPanel/Panel/Panel/Panel
TaskBoardMissionPanel/Panel/Panel/Panel/Label
TaskBoardMissionPanel/Panel/Panel/Panel/ScrollablePanel
TaskBoardMissionPanel/Panel/RectangleProgressBar
```
### progressPanel paths only in Custom
```text
ProgressPanel
ProgressPanel/HorizontalScrollBar
ProgressPanel/ScrollablePanel
ProgressPanel/ScrollablePanel/Panel
ProgressPanel/ScrollablePanel/Panel/for i = 0, 46 do
ProgressPanel/ScrollablePanel/Panel/for i = 0, 46 do/end
ProgressPanel/ScrollablePanel/Panel/for i = 0, 46 do/local widget = g_ui.createWidget('MapFragment', self)
ProgressPanel/ScrollablePanel/UICreature
```
### progressPanel paths only in TaskBoard
```text
TaskBoardProgressPanel
TaskBoardProgressPanel/Label
TaskBoardProgressPanel/Panel
TaskBoardProgressPanel/Panel/Label
TaskBoardProgressPanel/Panel/TaskBoardProgressTrack
TaskBoardProgressPanel/ScrollablePanel
```