# Отчёт о покрытии тестами — UXFeedbackSDK

**Дата:** 2026-09-09
**Схема:** `UXFeedbackSDKTests` · **Окружение:** iPhone 17 Pro (Simulator), iOS 26.5
**Метод:** `xcodebuild test -enableCodeCoverage YES`, result bundle `build/test-coverage.xcresult`

---

## 1. Сводка

| Показатель | Значение |
|---|---|
| Всего тестов | 417 |
| Прошло | 413 |
| Упало | 4 (см. раздел 5) |
| **Покрытие таргета `UXFeedbackSDK.framework`** | **61.72%** (10 165 / 16 470 строк) |
| **Покрытие собственного кода** (без вендорного YYImage/WebP, ~3 000 строк Obj-C) | **74.35%** (9 989 / 13 435) |

## 2. Динамика

| Итерация | Таргет | Собственный код |
|---|---|---|
| Исходное состояние | 14.29% | ~17% |
| + логика форм и UI (`DataManagerLogicTests`, `CampaignViewControllerTests`, `HeaderHeightTests`, `VendorUtilitiesTests`) | 37.21% | 45.62% |
| + сетевой слой (`NetworkLayerTests`: стаб `URLProtocol`, CoreData-очередь) | 45.98% | 55.06% |
| + фасад SDK (`UXFeedbackFacadeTests`: setup, startCampaign, презентер, Crypto) | 51.68% | 62.05% |
| + взаимодействия с ячейками (`CellInteractionTests`: тапы, выбор опций, ввод текста) | 55.44% | 66.65% |
| + навигация по страницам и мелкие вьюхи (`NavigationAndSmallViewsTests`) | 58.91% | 70.90% |
| + скриншот-подсистема, Reachability, passthrough-окна (`ScreenshotAndMiscTests`) | **61.72%** | **74.35%** |

---

## 3. Покрытие по слоям

### Фасад, сетевой слой и хранилище

| Файл | Покрытие |
|---|---|
| `UXFBTheme.swift` | 100% |
| `APIWebRouter.swift` (маршруты/заголовки) | 95% |
| `APIClient.swift` (HTTP-клиент, все методы API) | 91% |
| `DataRequestManager.swift` (CoreData-очередь запросов, ретраи) | 89% |
| **`UXFeedback.swift`** (публичный фасад: setup, startCampaign, делегаты) | **86%** |
| `Crypto.swift` | 79% |
| `CampaignManager.swift` (выбор кампании из кандидатов) | 74% |
| `CampaignPresentor.swift` (показ форм, хендлеры) | 46% |

### Модели и логика

| Файл | Покрытие |
|---|---|
| `Theme`, `Field`, `Option`, `Transform`, `Queue`, `UXFBSettings` и др. | 100% |
| `TextPropertyManager.swift` | 96% |
| `AttributeManager.swift` / `Attributes.swift` | 95% / 95% |
| `URLComponents.swift` | 92% |
| `Parser.swift` | 88% |
| `StatisticManager.swift` | 88% |
| **`DataManager.swift`** (раскладка форм, ответы, transforms, privacy, навигация) | **87%** |

### UI-слой

| Файл | Покрытие |
|---|---|
| `ImageCell` / `SliderView` / `VisualEffectView+` / `CheckCell` | 94–97% |
| `EmailCell` / `LinkLabel` / `InputCell` / `StarsCell` / `UIImageView+cache` | 88–90% |
| `RadioCell` / `NpsCell` / `RatingCell` / `BaseCell` | 84–87% |
| `ButtonCell` / `CheckboxCell` / `PrivacyView` / `HeaderView` / `SmilesCell` / `RadiobuttonCell` | 76–81% |
| `PassthroughWindow` / `ImageCollection` / `ScreenshotImageCell` | 84–100% |
| `Reachability` / `HeaderCell` / `TextCell` / `HtmlLabel` | 72–76% |
| **`CampaignViewController.swift`** | **65%** |
| `ScreenshotCell` / `ScreenshotCreator` | 65% / 55% |
| `VisualEffectView` / `Reachability+NetworkType` | 59% / 53% |

### Не покрыто (0%) — оставшийся резерв

| Файл | Строк | Причина / что нужно |
|---|---|---|
| `ImageManager` / `ImageSelector` / `ScreenshotCreator` / `ImageCollection` / `GalleryCell` / `ScreenshotImageCell` | ~1 370 | PhotosUI/разрешения — в основном UI-тесты |
| `Reachability*` (частично) | ~130 | Системные колбэки |
| `UIImageView+cache`, `SliderView`, `VisualEffectView*`, `PassthroughWindow`, мелкие расширения | ~350 | Достижимо юнит-тестами |
| `YYImage*` (вендорный Obj-C) | ~3 000 | Исключить из метрики |

Части `CampaignPresentor` (54%) и `UXFeedback` (14%), связанные с живой презентацией `UIWindow` и анимациями, достижимы только UI-тестами на демо-приложении.

---

## 4. Состав тестов

| Сьют | Тестов | Что покрывает |
|---|---|---|
| `UXFeedbackFacadeTests` | 12 | setup SDK, startCampaign (полный цикл до показа), Crypto, глобальные properties, хендлеры презентера, форвардинг делегатов |
| `CellInteractionTests` | 11 | Тапы по звёздам, выбор чекбоксов (вкл. exceptional), ввод в input/email, картинки в text/image/header, «нет ответа», LinkLabel |
| `NavigationAndSmallViewsTests` | 13 | Навигация по страницам, transforms (toPage/else/toURL), завершение кампании, SliderView, VisualEffectView, кэш картинок, retry ImageCell, смайлы |
| `ScreenshotAndMiscTests` | 12 | Passthrough-окна, ScreenshotImageCell/Creator, ImageCollection, Reachability, клавиатура slidein, жесты и закрытие формы, варианты картинок HeaderCell |
| `NetworkLayerTests` (APIClient / DataRequestManager / CampaignManager) | 21 | HTTP-клиент через стаб `URLProtocol`, CoreData-очередь, делегаты, выбор кампании |
| `DataManagerLogicTests` | 22 | Высоты всех полей, ответы, transforms, privacy, валидация |
| `CampaignViewControllerTests` | 16 | Жизненный цикл, датасорс (все 14 ячеек), обновления, клавиатура |
| `HeaderHeightTests` | 13 | Расчёт высоты блока «Заголовок» на разных ширинах |
| `VendorUtilitiesTests` | 10 | UIView/UIImage/контролы/скелетон/HtmlLabel |
| Ранее существовавшие сьюты | ~280 | Модели, парсер, атрибуты, роутер, крипто и др. |

---

## 5. Известные падающие тесты (существовали до текущих работ)

| Тест | Причина |
|---|---|
| `APIWebRouterTests/testHeadersWithSettings` | Ожидает заголовок `"Flutter"`, SDK возвращает `"Native"` |
| `NSAttributedStringExtensionTests/testHeightForEmptyString` | Высота пустой строки = 14.0 на iOS 26 (ожидалось 0) |
| `UIColorHexTests/testInvalidLengthThrows` | Инициализатор hex-цвета не бросает ошибку |
| `PrivacyTests/testPrivacyCodable` | Декодирование `Privacy`: `"all"` вместо `"always"` |

## 6. Замечания по поведению SDK, зафиксированные тестами

1. `DataManager.textChanged` не проставляет `pageId` — ответы полей «комментарий» не попадают в результаты `endCampaign` (потенциальный баг, тест фиксирует текущее поведение).
2. `APIClient.performRequest` определяет успех по содержимому JSON, игнорируя HTTP-статус: ответ 500 с валидным JSON трактуется как успех.

---

## 7. Статус и остаток

Цель — максимум покрытия юнит-тестами самого SDK (демо-приложение и UI-тесты вне скоупа).

**Реалистичный потолок юнит-тестов без host app (~75–80% собственного кода) практически достигнут: 74.35%.**

Оставшееся не покрыто по объективным причинам:

| Код | Строк | Причина |
|---|---|---|
| `ImageSelector` (0%), `GalleryCell` (0%), часть `ImageManager` | ~860 | PhotosUI: живые разрешения галереи, `PHAsset` |
| `ImageManager` (0%) | 324 | Полноэкранные `UIWindow`-презентации просмотра картинок |
| Части `CampaignViewController` (65%), `CampaignPresentor` (46%), `UXFeedback` (86%) | ~700 | Живая презентация форм, анимации переходов, реальные жесты |
| `UIAlertController+`, `UIViewController+present`, мелкие расширения | ~90 | Презентация алертов в отдельных окнах |
| `YYImage*` (вендорный Obj-C) | ~3 000 | Сторонний код — рекомендуется исключить из метрики |

Дальнейший рост метрики возможен в основном за счёт исключения вендорного кода из подсчёта (`xccov`-фильтр или вынос YYImage в отдельный таргет): тогда текущие 74.35% собственного кода и есть фактический показатель SDK.
