# Assets 图片资源说明

## 📁 目录结构

```
CityWalk/Assets.xcassets/
├── SuzhouGarden.imageset/          # 苏州园林图片
├── HangzhouWestlake.imageset/      # 杭州西湖图片
├── AccentColor.colorset/           # 主题色
├── AppIcon.appiconset/             # 应用图标
└── MockData_Trips/                 # Mock数据说明文件夹
```

## 🖼️ 图片命名规范

### Mock数据图片
- `SuzhouGarden` - 苏州园林相关图片
- `HangzhouWestlake` - 杭州西湖相关图片

### 代码引用方式
```swift
Image("SuzhouGarden")      // 苏州园林图片
Image("HangzhouWestlake")  // 杭州西湖图片
```

## 📝 注意事项

1. **SwiftUI限制**：Image() 不支持子文件夹路径，所有图片必须在根目录
2. **命名规范**：使用英文命名，避免空格和特殊字符
3. **多分辨率**：每个.imageset支持1x、2x、3x分辨率
4. **文件格式**：支持PNG、JPG、JPEG格式

## 🔧 添加新图片步骤

1. 在Xcode中右键Assets.xcassets
2. 选择"New Image Set"
3. 命名为英文（如：`BeijingPalace`）
4. 拖拽图片到对应分辨率槽位
5. 在代码中使用 `Image("BeijingPalace")` 