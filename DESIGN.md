# Subscriptions App 設計系統

## 概述
Subscriptions 是一個現代化的 iOS 訂閱管理應用，採用 SwiftUI 框架開發，具有簡潔優雅的設計風格，支援淺色和深色模式，並提供優秀的使用者體驗。

## 字體系統

### 字體家族
- **系統字體**: 使用 iOS 系統預設字體 (San Francisco)
- **設計風格**: `.default` - 保持系統一致性

### 字體層級

#### 標題字體
- **主標題**: `.system(size: 24, weight: .bold)` - 用於頁面標題
- **次級標題**: `.system(size: 20, weight: .bold)` - 用於區塊標題
- **區段標題**: `.system(size: 18, weight: .semibold)` - 用於設定區段

#### 內容字體
- **主要內容**: `.system(size: 16, weight: .semibold)` - 用於重要資訊
- **次要內容**: `.system(size: 14, weight: .medium)` - 用於描述文字
- **說明文字**: `.system(size: 13, weight: .regular)` - 用於詳細說明
- **按鈕文字**: `.system(size: 16, weight: .semibold)` - 用於動作按鈕

#### 特殊字體
- **大數字顯示**: `.system(size: 48, weight: .bold)` - 用於總金額顯示
- **類別詳情數字**: `.system(size: 36, weight: .bold)` - 用於類別總額
- **小標籤**: `.system(size: 12, weight: .semibold)` - 用於次要標籤
- **圖示文字**: `.system(size: 10)` - 用於下拉選單圖示

### 字體特性
- **字距調整**: 大數字使用 `.tracking(-1)` 改善視覺效果
- **小標籤字距**: 部分小標籤使用 `.tracking(0.5)` 增加可讀性

## 顏色系統

### 淺色模式配色
```swift
background: .white                    // 主背景色
secondaryBackground: Color(.systemGray6)  // 次要背景色 (#F2F2F7)
cardBackground: .white                // 卡片背景色
primaryText: .black                   // 主要文字色
secondaryText: .gray                  // 次要文字色
accent: .black                        // 主要強調色
border: Color(.systemGray4)           // 邊框顏色
destructive: .red                     // 危險/警告色
```

### 深色模式配色
```swift
background: Color(red: 0.11, green: 0.11, blue: 0.12)      // #1C1C1E - 主背景
secondaryBackground: Color(red: 0.17, green: 0.17, blue: 0.18)  // #2C2C2E - 次要背景
cardBackground: Color(red: 0.17, green: 0.17, blue: 0.18)      // #2C2C2E - 卡片背景
primaryText: Color(red: 0.98, green: 0.98, blue: 0.98)         // #FAFAFA - 主要文字
secondaryText: Color(red: 0.64, green: 0.64, blue: 0.67)       // #A3A3AB - 次要文字
accent: Color(red: 0.98, green: 0.98, blue: 0.98)              // #FAFAFA - 主要強調色
border: Color(red: 0.27, green: 0.27, blue: 0.29)              // #44444A - 邊框顏色
destructive: Color(red: 1.0, green: 0.27, blue: 0.23)          // #FF453A - 危險/警告色
```

## 設計風格

### 整體設計理念
- **極簡主義**: 乾淨簡潔的介面設計
- **內容優先**: 突出重要資訊，減少視覺雜訊
- **一致性**: 統一的設計語言和互動模式
- **可訪問性**: 支援多語言和主題切換

### 佈局設計

#### 間距系統
- **頁面邊距**: 24px 水平邊距
- **區塊間距**: 32px 用於主要區塊之間
- **內容間距**: 16px 用於相關內容之間
- **元素間距**: 8px 用於小元素之間
- **卡片內邊距**: 20px 水平，16px 垂直

#### 圓角設計
- **主要卡片**: 12px 圓角
- **大型卡片**: 16px 圓角
- **小元件**: 8px 圓角
- **圓形元件**: 完全圓形 (Circle())

### 元件設計

#### 按鈕設計
- **主要按鈕**: 
  - 背景色使用 accent 色
  - 文字色為背景色
  - 16px 垂直內邊距
  - 12px 圓角
  
- **次要按鈕**:
  - 透明背景
  - 1px 邊框
  - 與主要按鈕相同的內邊距和圓角

#### 卡片設計
- **基礎卡片**: 白色背景（淺色模式）或深灰背景（深色模式）
- **邊框**: 0.5-1px 細邊框，使用 border 顏色
- **陰影**: 不使用陰影，依賴邊框定義邊界

#### 列表設計
- **分隔線**: 0.5px 高度，30% 透明度
- **項目高度**: 靈活高度，最小 16px 垂直內邊距
- **選中狀態**: 98% 縮放效果，背景色變化

### 互動設計

#### 動畫效果
- **按壓回饋**: `.scaleEffect(0.98)` 縮放效果
- **動畫時長**: `.easeInOut(duration: 0.1)` 快速回應
- **狀態切換**: 平滑的顏色和透明度變化

#### 狀態指示
- **緊急狀態**: 3天內到期使用 destructive 顏色
- **正常狀態**: 使用 secondaryText 顏色
- **選中狀態**: checkmark 圖示 + 藍色強調

### 圖示系統
- **系統圖示**: 使用 SF Symbols 圖示系統
- **圖示大小**: 12px-32px 根據使用場景調整
- **圖示風格**: 統一使用 `.medium` 或 `.semibold` 權重

### 主題切換
- **支援模式**: 淺色、深色、跟隨系統
- **自動適配**: 顏色和對比度自動調整
- **一致體驗**: 所有元件都支援主題切換

## 設計原則

1. **可讀性優先**: 確保文字在所有主題下都清晰可讀
2. **觸控友好**: 按鈕和互動區域足夠大
3. **視覺層次**: 通過字體大小和顏色建立清晰的資訊層次
4. **品牌一致**: 保持整個應用的設計風格統一
5. **性能優化**: 避免複雜的視覺效果影響性能