## NYMB-MGridAssistant-MT5-Bot

Бот-ассистент сопровождает ручную сделку, автоматически усредняя ее двумя Мартингейл-сетками

* Designed by https://www.mql5.com/ru/job/233710
* Coded by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https:kislitsyn.me/personal/algo)
* Version: 1.00

## Оглавление
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [NYMB-MGridAssistant-MT5-Bot](#nymb-mgridassistant-mt5-bot)
- [Оглавление](#оглавление)
- [Что нового?](#что-нового)
- [Тех. задание](#тех-задание)
- [Стратегия](#стратегия)
- [Installation | Установка](#installation--установка)
  - [EN: Installation](#en-installation)
  - [RU: Установка](#ru-установка)
- [Build From Source | Компиляция исходников](#build-from-source--компиляция-исходников)
  - [EN: Build From Source](#en-build-from-source)
  - [RU: Компиляция исходников](#ru-компиляция-исходников)

<!-- /code_chunk_output -->


## Что нового?
```
1.00: First version
```

## Тех. задание

Бот для MetaTrader 5 (XAUUSD). Задача: Автоматизация стратегии с использованием Мартингейла и хеджирования. 

![Chart Requirements](img/UM001.%20Req.jpg)

**Основные особенности работы бота:**

 - [ ] 1. Открытие сделки:
      - [ ] • Пользователь вручную открывает первую основную позицию (лонг) с условиями:
      - [ ] • Take Profit (TP): 3%
      - [ ] • Stop Loss (SL): 1%
      - [ ] • В момент открытия основной сделки бот автоматически открывает хеджирующую позицию в противоположном направлении (шорт) с такими условиями:
      - [ ] • Take Profit (TP) хеджа: 1%
      - [ ] • Stop Loss (SL) хеджа: 0.33% (в пропорции 1:3 к TP хеджа)
      - [ ] ==У первой ручной сделки нет хедже первая сделка является так называемым включателем бота и все описаные условия роботы бота начинаються только после того ка первая сделка закроется по стоп лоссу==
      - [ ] ==Лотность так же переться с первой ручной сделки и дальше работает по описаной стратегии увеличению==
 - [ ] 2. Закрытие сделки по стоп-лоссу:
      - [ ] • Если основная позиция закрывается по Stop Loss (SL), бот ждёт первую минутную свечу, чтобы открыть новую сделку с теми же условиями:
      - [ ] • Take Profit (TP): 3%
      - [ ] • Stop Loss (SL): 1%
      - [ ] • При этом, хеджирующая позиция открывается с теми же условиями, что и у основной позиции, и расположена на уровне Stop Loss основной сделки:
      - [ ] • Take Profit хеджа: равен уровню Stop Loss основной сделки
      - [ ] • Stop Loss хеджа: пропорция 1:3, то есть 0.33% от TP хеджирующей сделки
      - [ ] ==Стоп лос хеджа закрылся и после него закрылся тейк основной позиции (тогда бот фиксирует прибыль и останавливает роботу )==
      - [ ] ==Стоп лос хеджа закрылся и после закрылся стоп лос основной позиции ( тогда бот открывает новою сделку на новой 1минутной свече сразу после закрытия по стоплосу  с увеличенным обьемом х2 по Мартингейлу и продожает работу)==
      - [ ] ==Хедж позиция закрываеться по тейк профиту вместе с стоп лососм основной позиции тогда бот октрывает новою сделку на новой 1 минутной свече с теми же условиями только не увеичивая обьем по мартингейлу в х2==
 - [ ] 3. Увеличение объёма при убыточных сделках:
      - [ ] • Если первая сделка (основная и хедж) закрывается по Stop Loss, то на следующей минутной свече:
      - [ ] • Бот открывает новую позицию с увеличением объёма в 2 раза по сравнению с предыдущей сделкой. Например, если первая сделка была 0.1 лота, вторая будет 0.2 лота.
      - [ ] ==Нет хедж и основаня позиция всегда имеют одинаковый обьем==
      - [ ] ==просто при рахных факторах обьем меняется==
      - [ ] ==Стоп лос хедж + Стопл лос основной (х2)==
      - [ ] ==Стопл лос хедж + Тейк основной (фиксирование прибли оставновка бота )==
      - [ ] ==Тейк профит хедж + Стоп лос основной ( открытие новой стелки на новой свече с теми же условиями и с тем же обьемом )==
 - [ ] 4. Закрытие хеджирующей позиции по Take Profit и основной позиции по Stop Loss:
      - [ ] • Если хеджирующая позиция закрывается по Take Profit (1%) и основная по Stop Loss (1%), бот откроет новую сделку с теми же условиями:
      - [ ] • Take Profit основной сделки: 3%
      - [ ] • Stop Loss основной сделки: 1%
      - [ ] • Хеджирующая позиция: открывается на уровне цены Stop Loss основной сделки, с Take Profit хеджа 1% и Stop Loss хеджа 0.33%.
      - [ ] • В этом случае объём сделки не увеличивается.
 - [ ] 5. Увеличение объёма при последовательных убытках:
      - [ ] • Если сначала хеджирующая позиция закрывается по Stop Loss, а затем основная позиция закрывается по Stop Loss, то на следующей минутной свече:
      - [ ] • Бот открывает новую сделку с теми же условиями (Take Profit 3%, Stop Loss 1%), но с увеличением объёма в 2 раза.
 - [ ] 6. Окончание стратегии:
      - [ ] • Процесс продолжается, пока основная позиция не закрывается по Take Profit. После этого бот начинает новый цикл с начальным объёмом и прежними условиями.


**Примечания:**
- [ ] Рынок: Стратегия должна работать с валютными парами (например, EUR/USD, XAU/USD и другие). Все параметры могут быть адаптированы под разные торговые инструменты.
- [ ] Таймфрейм: Все действия выполняются на 1-минутной свече. Бот должен точно отслеживать изменения на минутных свечах для принятия решения.
- [ ] Увеличение объёма: При увеличении объёма на x2, бот должен корректно рассчитывать объём на следующей сделке, исходя из объёма предыдущей.
- [ ] Тестирование: Необходимо провести тестирование стратегии на демо-счёте для анализа её эффективности и выявления возможных ошибок.

**Дополнительные требования:**
- [ ] Бот должен работать в реальном времени, отслеживая рыночные условия и открывая новые сделки только по завершению предыдущих.
- [ ] Необходимо предусмотреть систему уведомлений (например, через Telegram или email) для информирования пользователя о текущем статусе сделок и действиях бота.
- [ ] Все данные (открытие, закрытие сделок, параметры сделок и т.д.) должны быть записаны в лог для анализа и дальнейшего улучшения стратегии.


## Стратегия

## Installation | Установка

### EN: Installation

**1. Update MetaTrader 5 Terminal:** Ensure that your MetaTrader 5 terminal is updated to the latest version. For testing Expert Advisors, it is recommended to use the latest beta version. To update, go to `Help->Check For Updates->Latest Beta Version`. If your terminal is outdated, the Expert Advisor may not run, and you will see relevant messages in the `Journal` tab.
**2. Copy Indicator Files:** Move the `*.ex5` indicator files to the terminal’s data directory `MQL5\Indicators`.
**3. Copy the Expert Advisor File:** Move the `*.ex5` bot file to `MQL5\Experts`.
**4. Copy the Script File:** Move the `*.ex5` script file to `MQL5\Scripts`.
**5. Open the Symbol Chart:** Open the chart for the desired trading instrument.
**6. Attach the Expert Advisor to the Chart:** Drag the Expert Advisor from the Navigator window onto the chart.
**7. Enable Auto Trading in the Expert Advisor Settings:** In the Expert Advisor settings, check `Allow Auto Trading`.
**8. Allow DLL and WebRequests:**: If your Expert Advisor uses external DLL and makes network requests, enable the `Allow DLLs imports` and `Allow WebRequests for listed URLs` param in the terminal `Tools->Options` settings. Add the required ones to the list of external network addresses.
**9. Activate Auto Trading in the Terminal:** Click the `Algo Trading` button on the main toolbar to enable automated trading.
**10. Load the Preset Configuration:** Click the `Load` button and select the appropriate set-file to apply the predefined settings, if provided.

### RU: Установка
**1. Обновите терминал MetaTrader 5:** Убедитесь, что ваш терминал MetaTrader 5 обновлен до последней версии. Для тестирования Expert Advisors рекомендуется использовать последнюю бета-версию. Чтобы обновить, пройдите по ссылке `Help->Check For Updates->Latest Beta Version`. Если ваш терминал устарел, бот может не работать, и вы увидите соответствующие сообщения в вкладке `Journal`.
**2. Скопируйте файлы индикаторов:** Переместить файлы индикаторов `*.ex5` в директорию данных терминала `MQL5\Indicators`.
**3. Скопируйте файл советника:** Переместите файл `*.ex5` бота в `MQL5\Experts`.
**4. Скопируйте файлы скриптов:** Переместить файлы скриптов `*.ex5` в `MQL5\Scripts`.
**5. Откройте график символа:** Откройте график нужного торгового инструмента.
**6. Прикрепите эксперта к графику:** Перетащите эксперта в окно графика.
**7. Включите автоторговлю у советника:** В настройках бота выберите пункт `Allow Auto Trading`.
**8. Разрешите DLL и WebRequests:** Если ваш эксперт использует внешние DLL и выполняет сетевые запросы, то в настройках терминала `Tools->Options` включите настройки `Allow DLLs imports` и `Allow WebRequests for listed URL`. В список внешних сетевых адресов добавьте нужные.
**9. Включите автоторговлю в терминале:** Нажмите кнопку `Algo Trading` на главной панели инструментов.
**10. Загрузите сеты:** Нажмите кнопку `Load` и выберите соответствующий файл для применения предопределенных параметров, если они предусмотрены.

## Build From Source | Компиляция исходников

### EN: Build From Source 

1. Start the IDE in MetaTrader 5. Select `Tools\Meta Quotes Language Editor` in the menu.
2. Go to the `Experts\<Expert's Catalogue>` folder.
3. Open the `*.mqproj` file.
4. Select the `Build\Compile` menu item.
5. The terminal will compile a new file `*.ex5` in the same directory.

### RU: Компиляция исходников

1. Запустите IDE в MetaTrader 5. Выберите в меню `Tools\Meta Quotes Language Editor`.
2. Перейдите в папку `Experts\<Expert's Catalogue>`.
3. Открыть файл `*.mqproj`.
4. Выберите пункт меню `Build\Compile`.
5. Терминал будет компилировать новый файл `*.ex5` в том же самом каталоге.