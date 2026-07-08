-- BUILD: VOLTZUI-2.0.0-EMBEDDED-MOBILE-GUARD-20260708
--[[
    VoltzUI - Clean Roblox UI Library
    BUILD: VOLTZUI-2.0.0-EMBEDDED-MOBILE-GUARD-20260708
    Theme: clean dark + selectable accent presets
    External icons: https://github.com/Footagesus/Icons

    Designed for client-side Roblox/Luau environments that support HttpGet + loadstring.
    Includes persistent flags/config support through executor file APIs.
    In Studio, you can inject your own compatible icon provider with VoltzUI:SetIconProvider(provider).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local VoltzUI = {
    Version = "2.0.0",
    Build = "VOLTZUI-2.0.0-EMBEDDED-MOBILE-GUARD-20260708",
    IconProvider = nil,
    IconsLoaded = false,
    MobileInputGuardEmbedded = true,
}

local ICON_PACK_URLS = {
    lucide = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
    solar = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua",
    craft = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua",
    geist = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua",
    sfsymbols = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua",
    gravity = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua",
}

local Theme = {
    Accent = Color3.fromRGB(50, 180, 253),
    AccentLight = Color3.fromRGB(126, 218, 255),
    AccentDark = Color3.fromRGB(34, 145, 214),

    -- Window layers
    Background = Color3.fromRGB(12, 16, 22),
    Surface = Color3.fromRGB(18, 23, 31),

    -- Raised cards and control surfaces. These are deliberately brighter
    -- than the page so cards no longer look pressed into the background.
    Surface2 = Color3.fromRGB(34, 42, 54),
    Surface3 = Color3.fromRGB(45, 55, 70),
    SurfaceHover = Color3.fromRGB(40, 50, 64),
    Border = Color3.fromRGB(67, 80, 99),

    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(205, 214, 226),
    TextDim = Color3.fromRGB(153, 168, 188),

    Success = Color3.fromRGB(74, 222, 128),
    Danger = Color3.fromRGB(248, 113, 113),
    Warning = Color3.fromRGB(250, 204, 21),
}

-- Theme presets intentionally keep the same clean dark layout and change the
-- accent family. Midnight also applies a slightly deeper blue-black surface.
local BaseTheme = {
    Accent = Theme.Accent,
    AccentLight = Theme.AccentLight,
    AccentDark = Theme.AccentDark,
    Background = Theme.Background,
    Surface = Theme.Surface,
    Surface2 = Theme.Surface2,
    Surface3 = Theme.Surface3,
    SurfaceHover = Theme.SurfaceHover,
    Border = Theme.Border,
    Text = Theme.Text,
    TextMuted = Theme.TextMuted,
    TextDim = Theme.TextDim,
    Success = Theme.Success,
    Danger = Theme.Danger,
    Warning = Theme.Warning,
}

local ThemeDefinitions = {
    ["Ocean Blue"] = {
        Accent = Color3.fromRGB(50, 180, 253),
        AccentLight = Color3.fromRGB(126, 218, 255),
        AccentDark = Color3.fromRGB(34, 145, 214),
    },
    ["Royal Purple"] = {
        Accent = Color3.fromRGB(139, 92, 246),
        AccentLight = Color3.fromRGB(196, 181, 253),
        AccentDark = Color3.fromRGB(109, 40, 217),
    },
    ["Emerald"] = {
        Accent = Color3.fromRGB(52, 211, 153),
        AccentLight = Color3.fromRGB(167, 243, 208),
        AccentDark = Color3.fromRGB(5, 150, 105),
    },
    ["Rose"] = {
        Accent = Color3.fromRGB(244, 114, 182),
        AccentLight = Color3.fromRGB(251, 207, 232),
        AccentDark = Color3.fromRGB(219, 39, 119),
    },
    ["Amber"] = {
        Accent = Color3.fromRGB(251, 191, 36),
        AccentLight = Color3.fromRGB(253, 230, 138),
        AccentDark = Color3.fromRGB(217, 119, 6),
    },
    ["Crimson"] = {
        Accent = Color3.fromRGB(248, 113, 113),
        AccentLight = Color3.fromRGB(254, 202, 202),
        AccentDark = Color3.fromRGB(220, 38, 38),
    },
    ["Electric Cyan"] = {
        Accent = Color3.fromRGB(34, 211, 238),
        AccentLight = Color3.fromRGB(165, 243, 252),
        AccentDark = Color3.fromRGB(8, 145, 178),
    },
    ["Lime"] = {
        Accent = Color3.fromRGB(163, 230, 53),
        AccentLight = Color3.fromRGB(217, 249, 157),
        AccentDark = Color3.fromRGB(101, 163, 13),
    },
    ["Monochrome"] = {
        Accent = Color3.fromRGB(148, 163, 184),
        AccentLight = Color3.fromRGB(226, 232, 240),
        AccentDark = Color3.fromRGB(71, 85, 105),
    },
    ["Midnight"] = {
        Accent = Color3.fromRGB(96, 165, 250),
        AccentLight = Color3.fromRGB(191, 219, 254),
        AccentDark = Color3.fromRGB(37, 99, 235),
        Background = Color3.fromRGB(7, 12, 22),
        Surface = Color3.fromRGB(11, 18, 31),
        Surface2 = Color3.fromRGB(23, 34, 52),
        Surface3 = Color3.fromRGB(34, 48, 70),
        SurfaceHover = Color3.fromRGB(30, 45, 66),
        Border = Color3.fromRGB(54, 73, 99),
    },
}

local ThemeOrder = {
    "Ocean Blue",
    "Royal Purple",
    "Emerald",
    "Rose",
    "Amber",
    "Crimson",
    "Electric Cyan",
    "Lime",
    "Monochrome",
    "Midnight",
}

local ActiveThemeName = "Ocean Blue"


-- Built-in interface translations. Language names are intentionally shown in
-- their native form so users can recover the setting even after switching.
local LanguageDefinitions = {
    ["English"] = {
        Navigation = "NAVIGATION",
        SelectPlaceholder = "Select...",
        PressKey = "Press a key...",
        NoneText = "None",
        LanguageSectionTitle = "Language",
        LanguageSectionDesc = "Choose the interface language",
        LanguageControlTitle = "Interface language",
        LanguageControlDesc = "Change built-in VoltzUI text instantly",
        AppearanceTitle = "Appearance",
        AppearanceDesc = "Choose a color preset for the interface",
        ThemeColorTitle = "Theme color",
        ThemeColorDesc = "Change the interface accent instantly",
        ConfigurationTitle = "Configuration",
        ConfigurationDesc = "Save, load and manage multiple VoltzUI configs",
        ConfigFiles = "Config files",
        ConfigReady = "Config ready",
        ConfigDisabled = "Config disabled",
        ConfigEnableHint = "Enable Config in CreateWindow to save settings.",
        FolderLabel = "Folder",
        ActiveLabel = "Active",
        SavedConfigsTitle = "Saved configs",
        SavedConfigsDesc = "Choose a config file from your saved list",
        ConfigNameTitle = "Config name",
        ConfigNameDesc = "Type the name you want to save or load as",
        ConfigNamePlaceholder = "example_config",
        SaveConfigTitle = "Save config",
        SaveConfigDesc = "Save the current values into the typed config name",
        SaveButton = "Save",
        LoadConfigTitle = "Load config",
        LoadConfigDesc = "Load the selected config from the dropdown",
        LoadButton = "Load",
        RefreshConfigTitle = "Refresh list",
        RefreshConfigDesc = "Reload the dropdown from files inside your config folder",
        RefreshButton = "Refresh",
        DeleteConfigTitle = "Delete config",
        DeleteConfigDesc = "Delete the selected config file from disk",
        DeleteButton = "Delete",
        ResetDefaultsTitle = "Reset defaults",
        ResetDefaultsDesc = "Restore all saved controls to their default values",
        ResetButton = "Reset",
        ConfigSelected = "Config selected",
        ConfigSaved = "Config saved",
        ConfigLoaded = "Config loaded",
        ConfigListRefreshed = "Config list refreshed",
        ConfigDeleted = "Config deleted",
        DefaultsRestored = "Defaults restored",
        AutoloadLabel = "Autoload",
        NoAutoload = "None",
        SetAutoloadTitle = "Set as autoload",
        SetAutoloadDesc = "Load the selected config automatically next time the script runs",
        SetAutoloadButton = "Set",
        ClearAutoloadTitle = "Clear autoload",
        ClearAutoloadDesc = "Stop automatically loading a named config on startup",
        ClearAutoloadButton = "Clear",
        AutoloadSet = "Autoload config set",
        AutoloadCleared = "Autoload cleared",
        SaveBeforeAutoload = "Save this config before setting it as autoload",
    },
    ["ไทย"] = {
        Navigation = "เมนู",
        SelectPlaceholder = "เลือก...",
        PressKey = "กดปุ่มที่ต้องการ...",
        NoneText = "ไม่มี",
        LanguageSectionTitle = "ภาษา",
        LanguageSectionDesc = "เลือกภาษาของอินเทอร์เฟซ",
        LanguageControlTitle = "ภาษาอินเทอร์เฟซ",
        LanguageControlDesc = "เปลี่ยนข้อความพื้นฐานของ VoltzUI ได้ทันที",
        AppearanceTitle = "หน้าตาอินเทอร์เฟซ",
        AppearanceDesc = "เลือกชุดสีสำหรับอินเทอร์เฟซ",
        ThemeColorTitle = "ธีมสี",
        ThemeColorDesc = "เปลี่ยนสีหลักของอินเทอร์เฟซได้ทันที",
        ConfigurationTitle = "ไฟล์คอนฟิก",
        ConfigurationDesc = "บันทึก โหลด และจัดการคอนฟิกหลายไฟล์",
        ConfigFiles = "ไฟล์คอนฟิก",
        ConfigReady = "ระบบคอนฟิกพร้อมใช้งาน",
        ConfigDisabled = "ปิดระบบคอนฟิกอยู่",
        ConfigEnableHint = "เปิด Config ใน CreateWindow เพื่อบันทึกการตั้งค่า",
        FolderLabel = "โฟลเดอร์",
        ActiveLabel = "กำลังใช้",
        SavedConfigsTitle = "คอนฟิกที่บันทึกไว้",
        SavedConfigsDesc = "เลือกไฟล์คอนฟิกจากรายการที่บันทึกไว้",
        ConfigNameTitle = "ชื่อคอนฟิก",
        ConfigNameDesc = "กรอกชื่อไฟล์ที่ต้องการบันทึกหรือโหลด",
        ConfigNamePlaceholder = "ชื่อคอนฟิก",
        SaveConfigTitle = "บันทึกคอนฟิก",
        SaveConfigDesc = "บันทึกค่าปัจจุบันลงในชื่อคอนฟิกที่กรอก",
        SaveButton = "บันทึก",
        LoadConfigTitle = "โหลดคอนฟิก",
        LoadConfigDesc = "โหลดคอนฟิกที่เลือกจากรายการ",
        LoadButton = "โหลด",
        RefreshConfigTitle = "รีเฟรชรายการ",
        RefreshConfigDesc = "โหลดรายชื่อไฟล์คอนฟิกจากโฟลเดอร์ใหม่",
        RefreshButton = "รีเฟรช",
        DeleteConfigTitle = "ลบคอนฟิก",
        DeleteConfigDesc = "ลบไฟล์คอนฟิกที่เลือกออกจากเครื่อง",
        DeleteButton = "ลบ",
        ResetDefaultsTitle = "คืนค่าเริ่มต้น",
        ResetDefaultsDesc = "คืนค่าคอนโทรลทั้งหมดกลับเป็นค่าเริ่มต้น",
        ResetButton = "รีเซ็ต",
        ConfigSelected = "เลือกคอนฟิกแล้ว",
        ConfigSaved = "บันทึกคอนฟิกแล้ว",
        ConfigLoaded = "โหลดคอนฟิกแล้ว",
        ConfigListRefreshed = "รีเฟรชรายการคอนฟิกแล้ว",
        ConfigDeleted = "ลบคอนฟิกแล้ว",
        DefaultsRestored = "คืนค่าเริ่มต้นแล้ว",
        AutoloadLabel = "โหลดอัตโนมัติ",
        NoAutoload = "ไม่มี",
        SetAutoloadTitle = "ตั้งเป็นออโต้โหลด",
        SetAutoloadDesc = "โหลดคอนฟิกที่เลือกให้อัตโนมัติเมื่อรันสคริปต์ครั้งถัดไป",
        SetAutoloadButton = "ตั้งค่า",
        ClearAutoloadTitle = "ยกเลิกออโต้โหลด",
        ClearAutoloadDesc = "หยุดโหลดคอนฟิกที่ระบุอัตโนมัติเมื่อเริ่มสคริปต์",
        ClearAutoloadButton = "ยกเลิก",
        AutoloadSet = "ตั้งค่าออโต้โหลดแล้ว",
        AutoloadCleared = "ยกเลิกออโต้โหลดแล้ว",
        SaveBeforeAutoload = "กรุณาบันทึกคอนฟิกนี้ก่อนตั้งเป็นออโต้โหลด",
    },
    ["日本語"] = {
        Navigation = "ナビゲーション", SelectPlaceholder = "選択...", PressKey = "キーを押してください...", NoneText = "なし",
        LanguageSectionTitle = "言語", LanguageSectionDesc = "インターフェース言語を選択", LanguageControlTitle = "表示言語", LanguageControlDesc = "VoltzUI の標準テキストを変更します",
        AppearanceTitle = "外観", AppearanceDesc = "インターフェースの配色を選択", ThemeColorTitle = "テーマカラー", ThemeColorDesc = "アクセントカラーをすぐに変更",
        ConfigurationTitle = "設定ファイル", ConfigurationDesc = "複数の設定を保存・読込・管理", ConfigFiles = "設定ファイル", ConfigReady = "設定を使用できます", ConfigDisabled = "設定は無効です", ConfigEnableHint = "CreateWindow で Config を有効にしてください。",
        FolderLabel = "フォルダー", ActiveLabel = "使用中", SavedConfigsTitle = "保存済み設定", SavedConfigsDesc = "保存済み設定を選択", ConfigNameTitle = "設定名", ConfigNameDesc = "保存または読み込む名前を入力", ConfigNamePlaceholder = "設定名",
        SaveConfigTitle = "設定を保存", SaveConfigDesc = "現在の値を保存", SaveButton = "保存", LoadConfigTitle = "設定を読込", LoadConfigDesc = "選択した設定を読み込む", LoadButton = "読込",
        RefreshConfigTitle = "一覧を更新", RefreshConfigDesc = "設定ファイル一覧を再読込", RefreshButton = "更新", DeleteConfigTitle = "設定を削除", DeleteConfigDesc = "選択した設定を削除", DeleteButton = "削除",
        ResetDefaultsTitle = "初期値に戻す", ResetDefaultsDesc = "すべての項目を初期値に戻す", ResetButton = "リセット", ConfigSelected = "設定を選択しました", ConfigSaved = "設定を保存しました", ConfigLoaded = "設定を読み込みました", ConfigListRefreshed = "一覧を更新しました", ConfigDeleted = "設定を削除しました", DefaultsRestored = "初期値に戻しました",
    },
    ["简体中文"] = {
        Navigation = "导航", SelectPlaceholder = "选择...", PressKey = "请按一个键...", NoneText = "无",
        LanguageSectionTitle = "语言", LanguageSectionDesc = "选择界面语言", LanguageControlTitle = "界面语言", LanguageControlDesc = "即时更改 VoltzUI 内置文本",
        AppearanceTitle = "外观", AppearanceDesc = "选择界面配色", ThemeColorTitle = "主题颜色", ThemeColorDesc = "即时更改界面强调色",
        ConfigurationTitle = "配置", ConfigurationDesc = "保存、加载和管理多个配置", ConfigFiles = "配置文件", ConfigReady = "配置可用", ConfigDisabled = "配置已禁用", ConfigEnableHint = "请在 CreateWindow 中启用 Config。",
        FolderLabel = "文件夹", ActiveLabel = "当前", SavedConfigsTitle = "已保存配置", SavedConfigsDesc = "从已保存列表中选择配置", ConfigNameTitle = "配置名称", ConfigNameDesc = "输入要保存或加载的名称", ConfigNamePlaceholder = "配置名称",
        SaveConfigTitle = "保存配置", SaveConfigDesc = "将当前值保存到输入的配置名称", SaveButton = "保存", LoadConfigTitle = "加载配置", LoadConfigDesc = "加载下拉菜单中选择的配置", LoadButton = "加载",
        RefreshConfigTitle = "刷新列表", RefreshConfigDesc = "重新读取配置文件列表", RefreshButton = "刷新", DeleteConfigTitle = "删除配置", DeleteConfigDesc = "删除所选配置文件", DeleteButton = "删除",
        ResetDefaultsTitle = "恢复默认", ResetDefaultsDesc = "将所有控件恢复为默认值", ResetButton = "重置", ConfigSelected = "已选择配置", ConfigSaved = "配置已保存", ConfigLoaded = "配置已加载", ConfigListRefreshed = "配置列表已刷新", ConfigDeleted = "配置已删除", DefaultsRestored = "已恢复默认值",
    },
    ["한국어"] = {
        Navigation = "탐색", SelectPlaceholder = "선택...", PressKey = "키를 누르세요...", NoneText = "없음",
        LanguageSectionTitle = "언어", LanguageSectionDesc = "인터페이스 언어 선택", LanguageControlTitle = "인터페이스 언어", LanguageControlDesc = "VoltzUI 기본 문구를 즉시 변경합니다",
        AppearanceTitle = "모양", AppearanceDesc = "인터페이스 색상 선택", ThemeColorTitle = "테마 색상", ThemeColorDesc = "강조 색상을 즉시 변경합니다",
        ConfigurationTitle = "설정 파일", ConfigurationDesc = "여러 설정을 저장, 불러오기 및 관리", ConfigFiles = "설정 파일", ConfigReady = "설정 사용 가능", ConfigDisabled = "설정 비활성화됨", ConfigEnableHint = "CreateWindow에서 Config를 활성화하세요.",
        FolderLabel = "폴더", ActiveLabel = "현재", SavedConfigsTitle = "저장된 설정", SavedConfigsDesc = "저장된 설정을 선택하세요", ConfigNameTitle = "설정 이름", ConfigNameDesc = "저장하거나 불러올 이름을 입력하세요", ConfigNamePlaceholder = "설정 이름",
        SaveConfigTitle = "설정 저장", SaveConfigDesc = "현재 값을 입력한 이름으로 저장", SaveButton = "저장", LoadConfigTitle = "설정 불러오기", LoadConfigDesc = "선택한 설정을 불러오기", LoadButton = "불러오기",
        RefreshConfigTitle = "목록 새로고침", RefreshConfigDesc = "설정 파일 목록 다시 읽기", RefreshButton = "새로고침", DeleteConfigTitle = "설정 삭제", DeleteConfigDesc = "선택한 설정 파일 삭제", DeleteButton = "삭제",
        ResetDefaultsTitle = "기본값 복원", ResetDefaultsDesc = "모든 컨트롤을 기본값으로 복원", ResetButton = "초기화", ConfigSelected = "설정 선택됨", ConfigSaved = "설정 저장됨", ConfigLoaded = "설정 불러옴", ConfigListRefreshed = "목록 새로고침됨", ConfigDeleted = "설정 삭제됨", DefaultsRestored = "기본값 복원됨",
    },
    ["Español"] = {
        Navigation = "NAVEGACIÓN", SelectPlaceholder = "Seleccionar...", PressKey = "Pulsa una tecla...", NoneText = "Ninguno",
        LanguageSectionTitle = "Idioma", LanguageSectionDesc = "Elige el idioma de la interfaz", LanguageControlTitle = "Idioma de la interfaz", LanguageControlDesc = "Cambia el texto integrado de VoltzUI",
        AppearanceTitle = "Apariencia", AppearanceDesc = "Elige una paleta de colores", ThemeColorTitle = "Color del tema", ThemeColorDesc = "Cambia el color de acento al instante",
        ConfigurationTitle = "Configuración", ConfigurationDesc = "Guarda, carga y administra varias configuraciones", ConfigFiles = "Archivos de configuración", ConfigReady = "Configuración lista", ConfigDisabled = "Configuración desactivada", ConfigEnableHint = "Activa Config en CreateWindow.",
        FolderLabel = "Carpeta", ActiveLabel = "Activa", SavedConfigsTitle = "Configuraciones guardadas", SavedConfigsDesc = "Elige una configuración guardada", ConfigNameTitle = "Nombre de configuración", ConfigNameDesc = "Escribe el nombre para guardar o cargar", ConfigNamePlaceholder = "nombre_config",
        SaveConfigTitle = "Guardar configuración", SaveConfigDesc = "Guarda los valores actuales", SaveButton = "Guardar", LoadConfigTitle = "Cargar configuración", LoadConfigDesc = "Carga la configuración seleccionada", LoadButton = "Cargar",
        RefreshConfigTitle = "Actualizar lista", RefreshConfigDesc = "Vuelve a leer los archivos de configuración", RefreshButton = "Actualizar", DeleteConfigTitle = "Eliminar configuración", DeleteConfigDesc = "Elimina el archivo seleccionado", DeleteButton = "Eliminar",
        ResetDefaultsTitle = "Restablecer valores", ResetDefaultsDesc = "Restaura todos los controles", ResetButton = "Restablecer", ConfigSelected = "Configuración seleccionada", ConfigSaved = "Configuración guardada", ConfigLoaded = "Configuración cargada", ConfigListRefreshed = "Lista actualizada", ConfigDeleted = "Configuración eliminada", DefaultsRestored = "Valores restaurados",
    },
    ["Português"] = {
        Navigation = "NAVEGAÇÃO", SelectPlaceholder = "Selecionar...", PressKey = "Pressione uma tecla...", NoneText = "Nenhum",
        LanguageSectionTitle = "Idioma", LanguageSectionDesc = "Escolha o idioma da interface", LanguageControlTitle = "Idioma da interface", LanguageControlDesc = "Altere o texto integrado do VoltzUI",
        AppearanceTitle = "Aparência", AppearanceDesc = "Escolha uma paleta de cores", ThemeColorTitle = "Cor do tema", ThemeColorDesc = "Mude a cor de destaque instantaneamente",
        ConfigurationTitle = "Configuração", ConfigurationDesc = "Salve, carregue e gerencie várias configurações", ConfigFiles = "Arquivos de configuração", ConfigReady = "Configuração pronta", ConfigDisabled = "Configuração desativada", ConfigEnableHint = "Ative Config em CreateWindow.",
        FolderLabel = "Pasta", ActiveLabel = "Ativa", SavedConfigsTitle = "Configurações salvas", SavedConfigsDesc = "Escolha uma configuração salva", ConfigNameTitle = "Nome da configuração", ConfigNameDesc = "Digite o nome para salvar ou carregar", ConfigNamePlaceholder = "nome_config",
        SaveConfigTitle = "Salvar configuração", SaveConfigDesc = "Salve os valores atuais", SaveButton = "Salvar", LoadConfigTitle = "Carregar configuração", LoadConfigDesc = "Carregue a configuração selecionada", LoadButton = "Carregar",
        RefreshConfigTitle = "Atualizar lista", RefreshConfigDesc = "Leia novamente os arquivos de configuração", RefreshButton = "Atualizar", DeleteConfigTitle = "Excluir configuração", DeleteConfigDesc = "Exclua o arquivo selecionado", DeleteButton = "Excluir",
        ResetDefaultsTitle = "Restaurar padrões", ResetDefaultsDesc = "Restaure todos os controles", ResetButton = "Restaurar", ConfigSelected = "Configuração selecionada", ConfigSaved = "Configuração salva", ConfigLoaded = "Configuração carregada", ConfigListRefreshed = "Lista atualizada", ConfigDeleted = "Configuração excluída", DefaultsRestored = "Padrões restaurados",
    },
    ["Tiếng Việt"] = {
        Navigation = "ĐIỀU HƯỚNG", SelectPlaceholder = "Chọn...", PressKey = "Nhấn một phím...", NoneText = "Không có",
        LanguageSectionTitle = "Ngôn ngữ", LanguageSectionDesc = "Chọn ngôn ngữ giao diện", LanguageControlTitle = "Ngôn ngữ giao diện", LanguageControlDesc = "Đổi văn bản tích hợp của VoltzUI",
        AppearanceTitle = "Giao diện", AppearanceDesc = "Chọn bảng màu giao diện", ThemeColorTitle = "Màu chủ đề", ThemeColorDesc = "Đổi màu nhấn ngay lập tức",
        ConfigurationTitle = "Cấu hình", ConfigurationDesc = "Lưu, tải và quản lý nhiều cấu hình", ConfigFiles = "Tệp cấu hình", ConfigReady = "Cấu hình sẵn sàng", ConfigDisabled = "Cấu hình đã tắt", ConfigEnableHint = "Bật Config trong CreateWindow.",
        FolderLabel = "Thư mục", ActiveLabel = "Đang dùng", SavedConfigsTitle = "Cấu hình đã lưu", SavedConfigsDesc = "Chọn cấu hình trong danh sách", ConfigNameTitle = "Tên cấu hình", ConfigNameDesc = "Nhập tên để lưu hoặc tải", ConfigNamePlaceholder = "ten_cau_hinh",
        SaveConfigTitle = "Lưu cấu hình", SaveConfigDesc = "Lưu giá trị hiện tại", SaveButton = "Lưu", LoadConfigTitle = "Tải cấu hình", LoadConfigDesc = "Tải cấu hình đã chọn", LoadButton = "Tải",
        RefreshConfigTitle = "Làm mới danh sách", RefreshConfigDesc = "Đọc lại danh sách tệp cấu hình", RefreshButton = "Làm mới", DeleteConfigTitle = "Xóa cấu hình", DeleteConfigDesc = "Xóa tệp cấu hình đã chọn", DeleteButton = "Xóa",
        ResetDefaultsTitle = "Khôi phục mặc định", ResetDefaultsDesc = "Khôi phục tất cả điều khiển", ResetButton = "Đặt lại", ConfigSelected = "Đã chọn cấu hình", ConfigSaved = "Đã lưu cấu hình", ConfigLoaded = "Đã tải cấu hình", ConfigListRefreshed = "Đã làm mới danh sách", ConfigDeleted = "Đã xóa cấu hình", DefaultsRestored = "Đã khôi phục mặc định",
    },
}

local LanguageOrder = {
    "English",
    "ไทย",
    "日本語",
    "简体中文",
    "한국어",
    "Español",
    "Português",
    "Tiếng Việt",
}

local LanguageAliases = {
    ["en"] = "English", ["english"] = "English",
    ["th"] = "ไทย", ["thai"] = "ไทย", ["ไทย"] = "ไทย",
    ["ja"] = "日本語", ["jp"] = "日本語", ["japanese"] = "日本語", ["日本語"] = "日本語",
    ["zh"] = "简体中文", ["zh-cn"] = "简体中文", ["chinese"] = "简体中文", ["简体中文"] = "简体中文",
    ["ko"] = "한국어", ["korean"] = "한국어", ["한국어"] = "한국어",
    ["es"] = "Español", ["spanish"] = "Español", ["español"] = "Español",
    ["pt"] = "Português", ["portuguese"] = "Português", ["português"] = "Português",
    ["vi"] = "Tiếng Việt", ["vietnamese"] = "Tiếng Việt", ["tiếng việt"] = "Tiếng Việt",
}

local ActiveLanguageName = "English"

local function resolveLanguage(languageSpec)
    local raw = tostring(languageSpec or "English")
    if LanguageDefinitions[raw] then
        return raw
    end
    return LanguageAliases[raw:lower()] or "English"
end

local function translate(languageName, key, fallback)
    local selected = LanguageDefinitions[resolveLanguage(languageName)] or LanguageDefinitions.English
    local english = LanguageDefinitions.English
    return selected[key] or english[key] or fallback or tostring(key)
end

function VoltzUI:GetLanguageNames()
    local result = {}
    for _, name in ipairs(LanguageOrder) do
        table.insert(result, name)
    end
    return result
end

function VoltzUI:AddLanguage(name, dictionary, aliases)
    assert(type(name) == "string" and name ~= "", "Language name must be a non-empty string")
    assert(type(dictionary) == "table", "Language dictionary must be a table")

    LanguageDefinitions[name] = dictionary
    local exists = false
    for _, current in ipairs(LanguageOrder) do
        if current == name then
            exists = true
            break
        end
    end
    if not exists then
        table.insert(LanguageOrder, name)
    end

    LanguageAliases[name:lower()] = name
    if type(aliases) == "table" then
        for _, alias in ipairs(aliases) do
            LanguageAliases[tostring(alias):lower()] = name
        end
    end
    return self
end

-- Thai-capable font system.
-- NotoSansThai is preferred; safe fallbacks prevent the library from failing
-- when a specific font family is unavailable in the current Roblox build.
local FONT_FALLBACKS = {
    "NotoSansThai",
    "NotoSans",
    "BuilderSans",
    "Gotham",
}

local FONT_WEIGHTS = {
    Regular = Enum.FontWeight.Regular,
    Medium = Enum.FontWeight.Medium,
    SemiBold = Enum.FontWeight.SemiBold,
}

local ActiveFontFamily = "NotoSansThai"
local ActiveFonts = {}
local ActiveFontScale = 1.10

local function tryFontFromName(family, weight)
    if type(family) ~= "string" or family == "" then
        return nil
    end

    local success, result = pcall(function()
        return Font.fromName(family, weight, Enum.FontStyle.Normal)
    end)

    if success and result then
        return result
    end
    return nil
end

local function fallbackFont(weight)
    local success, result = pcall(function()
        return Font.new(
            "rbxasset://fonts/families/GothamSSm.json",
            weight,
            Enum.FontStyle.Normal
        )
    end)

    if success and result then
        return result
    end

    -- BuilderSans should exist on modern clients and remains the final fallback.
    return Font.fromName("BuilderSans", weight, Enum.FontStyle.Normal)
end

local function resolveFontForRole(spec, role)
    local weight = FONT_WEIGHTS[role] or Enum.FontWeight.Regular

    if typeof(spec) == "Font" then
        return Font.new(spec.Family, weight, spec.Style)
    end

    if type(spec) == "table" then
        local direct = spec[role] or spec[role:lower()]
        if typeof(direct) == "Font" then
            return direct
        end
    end

    local requestedFamily
    if type(spec) == "string" then
        requestedFamily = spec
    elseif type(spec) == "table" then
        requestedFamily = spec.Family or spec.Name
    end

    local checked = {}
    local candidates = {}
    if requestedFamily and requestedFamily ~= "" then
        table.insert(candidates, requestedFamily)
    end
    for _, family in ipairs(FONT_FALLBACKS) do
        table.insert(candidates, family)
    end

    for _, family in ipairs(candidates) do
        if not checked[family] then
            checked[family] = true
            local font = tryFontFromName(family, weight)
            if font then
                return font, family
            end
        end
    end

    return fallbackFont(weight), "Gotham"
end

local function applyFontSpec(spec)
    local family = type(spec) == "string" and spec
        or (type(spec) == "table" and (spec.Family or spec.Name))
        or "NotoSansThai"

    local resolved = {}
    local resolvedFamily = family
    for role in pairs(FONT_WEIGHTS) do
        local font, actualFamily = resolveFontForRole(spec or family, role)
        resolved[role] = font
        if actualFamily then
            resolvedFamily = actualFamily
        end
    end

    ActiveFontFamily = resolvedFamily or family
    ActiveFonts = resolved

    local explicitScale = type(spec) == "table" and tonumber(spec.Scale or spec.FontScale)
    if explicitScale then
        ActiveFontScale = math.clamp(explicitScale, 0.8, 1.5)
    else
        local requestedName = tostring(family or ActiveFontFamily):lower()
        ActiveFontScale = requestedName:find("thai", 1, true) and 1.10 or 1.0
    end

    VoltzUI.FontFamily = ActiveFontFamily
    VoltzUI.Fonts = ActiveFonts
    VoltzUI.FontScale = ActiveFontScale
end

local function fontFace(role)
    return ActiveFonts[role] or ActiveFonts.Regular or fallbackFont(Enum.FontWeight.Regular)
end

local function fontSize(baseSize)
    local numeric = tonumber(baseSize) or 12
    return math.max(1, math.floor((numeric * ActiveFontScale) + 0.5))
end

applyFontSpec("NotoSansThai")

function VoltzUI:SetFont(fontSpec, scale)
    if scale ~= nil and type(fontSpec) == "string" then
        fontSpec = {
            Family = fontSpec,
            Scale = scale,
        }
    end
    applyFontSpec(fontSpec or "NotoSansThai")
    return self
end

function VoltzUI:SetFontScale(scale)
    ActiveFontScale = math.clamp(tonumber(scale) or ActiveFontScale, 0.8, 1.5)
    self.FontScale = ActiveFontScale
    return self
end

function VoltzUI:GetFont()
    return self.FontFamily, self.Fonts, self.FontScale
end

local function cloneTable(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local THEME_COLOR_KEYS = {
    "Accent",
    "AccentLight",
    "AccentDark",
    "Background",
    "Surface",
    "Surface2",
    "Surface3",
    "SurfaceHover",
    "Border",
    "Text",
    "TextMuted",
    "TextDim",
    "Success",
    "Danger",
    "Warning",
}

local function composeTheme(overrides)
    local palette = cloneTable(BaseTheme)
    if type(overrides) == "table" then
        for key, value in pairs(overrides) do
            if typeof(value) == "Color3" then
                palette[key] = value
            end
        end
    end
    return palette
end

local function findThemeName(name)
    local requested = tostring(name or ""):lower()
    for _, themeName in ipairs(ThemeOrder) do
        if themeName:lower() == requested then
            return themeName
        end
    end
    return nil
end

local function resolveTheme(themeSpec)
    if type(themeSpec) == "string" then
        local name = findThemeName(themeSpec) or "Ocean Blue"
        return name, composeTheme(ThemeDefinitions[name])
    end

    if type(themeSpec) == "table" then
        local requestedPreset = themeSpec.Preset or themeSpec.Name
        local presetName = findThemeName(requestedPreset)
        local palette = composeTheme(presetName and ThemeDefinitions[presetName] or nil)
        for key, value in pairs(themeSpec) do
            if typeof(value) == "Color3" then
                palette[key] = value
            end
        end
        return presetName or tostring(themeSpec.Name or "Custom"), palette
    end

    return "Ocean Blue", composeTheme(ThemeDefinitions["Ocean Blue"])
end

local function applyThemePalette(palette)
    for _, key in ipairs(THEME_COLOR_KEYS) do
        if typeof(palette[key]) == "Color3" then
            Theme[key] = palette[key]
        end
    end
end

local function mappedThemeColor(color, oldPalette, newPalette)
    for _, key in ipairs(THEME_COLOR_KEYS) do
        if oldPalette[key] == color and newPalette[key] then
            return newPalette[key]
        end
    end
    return nil
end

local function recolorGuiTree(root, oldPalette, newPalette)
    if not root then
        return
    end

    local objects = { root }
    for _, descendant in ipairs(root:GetDescendants()) do
        table.insert(objects, descendant)
    end

    for _, object in ipairs(objects) do
        if object:IsA("GuiObject") then
            local mappedBackground = mappedThemeColor(object.BackgroundColor3, oldPalette, newPalette)
            if mappedBackground then
                object.BackgroundColor3 = mappedBackground
            end
        end

        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            local mappedText = mappedThemeColor(object.TextColor3, oldPalette, newPalette)
            if mappedText then
                object.TextColor3 = mappedText
            end
        end

        if object:IsA("TextBox") then
            local mappedPlaceholder = mappedThemeColor(object.PlaceholderColor3, oldPalette, newPalette)
            if mappedPlaceholder then
                object.PlaceholderColor3 = mappedPlaceholder
            end
        end

        if object:IsA("ImageLabel") or object:IsA("ImageButton") then
            local mappedImage = mappedThemeColor(object.ImageColor3, oldPalette, newPalette)
            if mappedImage then
                object.ImageColor3 = mappedImage
            end
        end

        if object:IsA("ScrollingFrame") then
            local mappedScroll = mappedThemeColor(object.ScrollBarImageColor3, oldPalette, newPalette)
            if mappedScroll then
                object.ScrollBarImageColor3 = mappedScroll
            end
        end

        if object:IsA("UIStroke") then
            local mappedStroke = mappedThemeColor(object.Color, oldPalette, newPalette)
            if mappedStroke then
                object.Color = mappedStroke
            end
        elseif object:IsA("UIGradient") then
            local keypoints = {}
            for _, point in ipairs(object.Color.Keypoints) do
                table.insert(keypoints, ColorSequenceKeypoint.new(
                    point.Time,
                    mappedThemeColor(point.Value, oldPalette, newPalette) or point.Value
                ))
            end
            object.Color = ColorSequence.new(keypoints)
        end
    end
end

function VoltzUI:RegisterTheme(name, colors)
    assert(type(name) == "string" and name ~= "", "Theme name must be a non-empty string")
    assert(type(colors) == "table", "Theme colors must be a table")

    local existing = findThemeName(name)
    if not existing then
        table.insert(ThemeOrder, name)
    end
    ThemeDefinitions[existing or name] = colors
    return self
end

function VoltzUI:GetThemeNames()
    local result = {}
    for _, name in ipairs(ThemeOrder) do
        table.insert(result, name)
    end
    return result
end

function VoltzUI:SetTheme(themeSpec)
    if self.ActiveWindow
        and self.ActiveWindow.ScreenGui
        and self.ActiveWindow.ScreenGui.Parent
        and type(self.ActiveWindow.SetTheme) == "function" then
        self.ActiveWindow:SetTheme(themeSpec)
        return self
    end

    local name, palette = resolveTheme(themeSpec)
    applyThemePalette(palette)
    ActiveThemeName = name
    self.DefaultTheme = name
    return self
end

function VoltzUI:GetTheme()
    return ActiveThemeName, cloneTable(Theme)
end

local function deepClone(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, item in pairs(value) do
        result[deepClone(key)] = deepClone(item)
    end
    return result
end

local function sanitizeName(value, fallback)
    local result = tostring(value or fallback or "default")
    result = result:gsub("[^%w%._%-]", "_")
    if result == "" then
        result = fallback or "default"
    end
    return result
end

local function buildConfigPath(folder, fileName)
    local safeFolder = sanitizeName(folder or "voltz", "voltz")
    local safeName = sanitizeName(fileName or "settings", "settings")
    return safeFolder .. "/" .. safeName .. ".json", safeName
end

local function listConfigNames(folder)
    local names = {}
    if type(listfiles) == "function" then
        local ok, files = pcall(listfiles, folder)
        if ok and type(files) == "table" then
            for _, filePath in ipairs(files) do
                local normalized = tostring(filePath):gsub(string.char(92), "/")
                local name = normalized:match("([^/]+)%.json$")
                if name and name ~= "" then
                    names[name] = true
                end
            end
        end
    end

    local result = {}
    for name in pairs(names) do
        table.insert(result, name)
    end
    table.sort(result, function(a, b)
        return tostring(a):lower() < tostring(b):lower()
    end)
    return result
end

local function normalizeConfigOptions(raw)
    if raw == true then
        raw = { Enabled = true }
    elseif type(raw) ~= "table" then
        raw = {}
    end

    local folder = sanitizeName(raw.Folder or "voltz", "voltz")
    local fileName = sanitizeName(raw.FileName or raw.Name or "settings", "settings")
    local path = buildConfigPath(folder, fileName)

    local autoloadFileName = sanitizeName(raw.AutoloadFileName or "__autoload", "__autoload")

    local config = {
        Enabled = raw.Enabled == true,
        Folder = folder,
        FileName = fileName,
        AutoLoad = raw.AutoLoad ~= false,
        AutoSave = raw.AutoSave ~= false,
        SaveWindowPosition = raw.SaveWindowPosition ~= false,
        SaveSelectedTab = raw.SaveSelectedTab ~= false,
        SaveMinimized = raw.SaveMinimized == true,
        AutoSaveDelay = math.max(tonumber(raw.AutoSaveDelay) or 0.35, 0.1),
        AutoloadFileName = autoloadFileName,
        AutoloadName = nil,
    }

    config.Path = path
    config.AutoloadPath = folder .. "/" .. autoloadFileName .. ".json"
    return config
end

local function fileSystemAvailable()
    return type(readfile) == "function"
        and type(writefile) == "function"
        and type(isfile) == "function"
end

local function ensureFolder(folder)
    if folder == "" then
        return true
    end

    if type(isfolder) == "function" then
        local ok, exists = pcall(isfolder, folder)
        if ok and exists then
            return true
        end
    end

    if type(makefolder) == "function" then
        local ok = pcall(makefolder, folder)
        return ok
    end

    return false
end

local function readAutoloadConfigName(config)
    if not config.Enabled or not config.AutoLoad or not fileSystemAvailable() then
        return nil
    end

    local existsOk, exists = pcall(isfile, config.AutoloadPath)
    if not existsOk or not exists then
        return nil
    end

    local readOk, source = pcall(readfile, config.AutoloadPath)
    if not readOk or type(source) ~= "string" or source == "" then
        return nil
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(source)
    end)
    if not decodeOk then
        return nil
    end

    local rawName
    if type(decoded) == "table" then
        rawName = decoded.FileName or decoded.Name
    elseif type(decoded) == "string" then
        rawName = decoded
    end

    if type(rawName) ~= "string" or rawName == "" then
        return nil
    end

    local _, safeName = buildConfigPath(config.Folder, rawName)
    return safeName
end

local function writeAutoloadConfigName(config, fileName)
    if not config.Enabled then
        return false, "Config is disabled"
    end
    if not fileSystemAvailable() then
        return false, "Executor does not support readfile/writefile/isfile"
    end

    ensureFolder(config.Folder)
    local _, safeName = buildConfigPath(config.Folder, fileName)
    local payload = {
        Version = 1,
        FileName = safeName,
    }

    local encodeOk, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not encodeOk then
        return false, "Unable to encode autoload config: " .. tostring(encoded)
    end

    local writeOk, writeError = pcall(writefile, config.AutoloadPath, encoded)
    if not writeOk then
        return false, "Unable to write autoload config: " .. tostring(writeError)
    end

    config.AutoloadName = safeName
    return true, safeName
end

local function clearAutoloadConfigName(config)
    if not config.Enabled then
        return false, "Config is disabled"
    end
    if not fileSystemAvailable() then
        return false, "Executor does not support file functions"
    end

    local existsOk, exists = pcall(isfile, config.AutoloadPath)
    if existsOk and exists then
        if type(delfile) == "function" then
            local deleteOk, deleteError = pcall(delfile, config.AutoloadPath)
            if not deleteOk then
                return false, tostring(deleteError)
            end
        else
            local encodeOk, encoded = pcall(function()
                return HttpService:JSONEncode({ Version = 1, FileName = "" })
            end)
            if not encodeOk then
                return false, tostring(encoded)
            end
            local writeOk, writeError = pcall(writefile, config.AutoloadPath, encoded)
            if not writeOk then
                return false, tostring(writeError)
            end
        end
    end

    config.AutoloadName = nil
    return true, config.AutoloadPath
end

local function serializeValue(value)
    local valueType = typeof(value)

    if valueType == "EnumItem" then
        return {
            __voltzType = "EnumItem",
            EnumType = tostring(value.EnumType),
            Name = value.Name,
        }
    elseif valueType == "Color3" then
        return {
            __voltzType = "Color3",
            R = value.R,
            G = value.G,
            B = value.B,
        }
    elseif valueType == "UDim2" then
        return {
            __voltzType = "UDim2",
            XS = value.X.Scale,
            XO = value.X.Offset,
            YS = value.Y.Scale,
            YO = value.Y.Offset,
        }
    elseif valueType == "Vector2" then
        return {
            __voltzType = "Vector2",
            X = value.X,
            Y = value.Y,
        }
    elseif type(value) == "table" then
        local result = {}
        for key, item in pairs(value) do
            result[tostring(key)] = serializeValue(item)
        end
        return result
    end

    return value
end

local function deserializeValue(value)
    if type(value) ~= "table" then
        return value
    end

    if value.__voltzType == "EnumItem" then
        local enumName = tostring(value.EnumType or ""):match("Enum%.(.+)")
        local enumType = enumName and Enum[enumName]
        if enumType and value.Name then
            return enumType[value.Name]
        end
        return nil
    elseif value.__voltzType == "Color3" then
        return Color3.new(tonumber(value.R) or 0, tonumber(value.G) or 0, tonumber(value.B) or 0)
    elseif value.__voltzType == "UDim2" then
        return UDim2.new(
            tonumber(value.XS) or 0,
            tonumber(value.XO) or 0,
            tonumber(value.YS) or 0,
            tonumber(value.YO) or 0
        )
    elseif value.__voltzType == "Vector2" then
        return Vector2.new(tonumber(value.X) or 0, tonumber(value.Y) or 0)
    end

    local result = {}
    for key, item in pairs(value) do
        result[key] = deserializeValue(item)
    end
    return result
end

local function readConfigData(config)
    if not config.Enabled then
        return nil, "Config is disabled"
    end

    if not fileSystemAvailable() then
        return nil, "Executor file functions are unavailable"
    end

    local existsOk, exists = pcall(isfile, config.Path)
    if not existsOk or not exists then
        return nil, "Config file does not exist"
    end

    local readOk, source = pcall(readfile, config.Path)
    if not readOk or type(source) ~= "string" or source == "" then
        return nil, "Unable to read config file"
    end

    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(source)
    end)
    if not decodeOk or type(decoded) ~= "table" then
        return nil, "Config JSON is invalid"
    end

    return decoded
end

local function merge(defaults, options)
    local result = cloneTable(defaults)
    if type(options) == "table" then
        for key, value in pairs(options) do
            result[key] = value
        end
    end
    return result
end

local function create(className, properties, children)
    local object = Instance.new(className)

    if properties then
        for property, value in pairs(properties) do
            if property ~= "Parent" then
                object[property] = value
            end
        end
    end

    if children then
        for _, child in ipairs(children) do
            child.Parent = object
        end
    end

    if properties and properties.Parent then
        object.Parent = properties.Parent
    end

    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent,
    })
end

local function tween(object, duration, properties, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.18,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local animation = TweenService:Create(object, tweenInfo, properties)
    animation:Play()
    return animation
end

-- Roblox normally scrolls ScrollingFrame objects on touch, but some mobile
-- executors and nested interactive controls can swallow the drag gesture.
-- This registry provides a touch-only fallback and always chooses the
-- top-most/smallest scrolling frame under the finger (for example, an open
-- dropdown instead of the page behind it).
local TouchScrollRegistry = setmetatable({}, { __mode = "k" })
local ActiveTouchScroll = nil
local TouchScrollConnectionsBound = false

local function isGuiTreeVisible(guiObject)
    if not guiObject or not guiObject.Parent then
        return false
    end

    local current = guiObject
    while current do
        if current:IsA("GuiObject") then
            if not current.Visible then
                return false
            end
            if current.AbsoluteSize.X <= 0 or current.AbsoluteSize.Y <= 0 then
                return false
            end
        end
        if current:IsA("ScreenGui") then
            return current.Enabled
        end
        current = current.Parent
    end

    return true
end

local function pointInsideGui(guiObject, point)
    local position = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize
    return point.X >= position.X
        and point.Y >= position.Y
        and point.X <= position.X + size.X
        and point.Y <= position.Y + size.Y
end

local function effectiveGuiScale(guiObject)
    local scale = 1
    local current = guiObject

    while current do
        local uiScale = current:FindFirstChildOfClass("UIScale")
        if uiScale then
            scale = scale * math.max(uiScale.Scale, 0.01)
        end
        current = current.Parent
    end

    return math.max(scale, 0.01)
end

local function maxCanvasPositionY(scrollingFrame)
    -- CanvasPosition is expressed in the ScrollingFrame's unscaled UI units.
    -- AbsoluteSize is rendered after UIScale, so convert the viewport back to
    -- logical units before clamping the canvas position.
    local scale = effectiveGuiScale(scrollingFrame)
    local canvasHeight = scrollingFrame.CanvasSize.Y.Offset
        + (scrollingFrame.CanvasSize.Y.Scale * (scrollingFrame.AbsoluteSize.Y / scale))
    local viewportHeight = scrollingFrame.AbsoluteSize.Y / scale

    return math.max(0, canvasHeight - viewportHeight)
end

local function bindTouchScrollConnections()
    if TouchScrollConnectionsBound then
        return
    end
    TouchScrollConnectionsBound = true

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local point = input.Position
        local bestFrame = nil
        local bestZIndex = -math.huge
        local bestArea = math.huge

        for scrollingFrame, enabled in pairs(TouchScrollRegistry) do
            if enabled
                and scrollingFrame:IsA("ScrollingFrame")
                and scrollingFrame.ScrollingEnabled == false
                and isGuiTreeVisible(scrollingFrame)
                and pointInsideGui(scrollingFrame, point)
                and maxCanvasPositionY(scrollingFrame) > 0.5 then

                local area = scrollingFrame.AbsoluteSize.X * scrollingFrame.AbsoluteSize.Y
                local zIndex = scrollingFrame.ZIndex
                if zIndex > bestZIndex or (zIndex == bestZIndex and area < bestArea) then
                    bestFrame = scrollingFrame
                    bestZIndex = zIndex
                    bestArea = area
                end
            end
        end

        if bestFrame then
            ActiveTouchScroll = {
                Input = input,
                Frame = bestFrame,
                StartPosition = input.Position,
                StartCanvas = bestFrame.CanvasPosition,
                LastPosition = input.Position,
                LastTime = os.clock(),
                Velocity = 0,
                Dragging = false,
            }
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        local state = ActiveTouchScroll
        if not state or input ~= state.Input then
            return
        end

        local frame = state.Frame
        if not frame or not frame.Parent then
            ActiveTouchScroll = nil
            return
        end

        local delta = input.Position - state.StartPosition
        if not state.Dragging then
            if math.abs(delta.Y) < 7 then
                return
            end
            if math.abs(delta.Y) < math.abs(delta.X) * 0.6 then
                return
            end
            state.Dragging = true
        end

        local scale = effectiveGuiScale(frame)
        local targetY = state.StartCanvas.Y - (delta.Y / scale)
        targetY = math.clamp(targetY, 0, maxCanvasPositionY(frame))
        frame.CanvasPosition = Vector2.new(0, targetY)

        local now = os.clock()
        local elapsed = math.max(now - state.LastTime, 1 / 240)
        state.Velocity = -((input.Position.Y - state.LastPosition.Y) / scale) / elapsed
        state.LastPosition = input.Position
        state.LastTime = now
    end)

    UserInputService.InputEnded:Connect(function(input)
        local state = ActiveTouchScroll
        if not state or input ~= state.Input then
            return
        end
        ActiveTouchScroll = nil

        local frame = state.Frame
        if not state.Dragging or not frame or not frame.Parent then
            return
        end

        local velocity = math.clamp(state.Velocity or 0, -2200, 2200)
        if math.abs(velocity) < 80 then
            return
        end

        local duration = math.clamp(math.abs(velocity) / 4200, 0.12, 0.42)
        local targetY = math.clamp(
            frame.CanvasPosition.Y + (velocity * duration * 0.36),
            0,
            maxCanvasPositionY(frame)
        )

        tween(frame, duration, {
            CanvasPosition = Vector2.new(0, targetY),
        }, Enum.EasingStyle.Quint)
    end)
end

local function registerTouchScrolling(scrollingFrame, enabled)
    local shouldUseFallback = enabled == true
        and UserInputService.TouchEnabled

    if shouldUseFallback then
        -- Programmatic CanvasPosition updates continue to work while native
        -- scrolling is disabled, preventing the same drag from being applied twice.
        scrollingFrame.ScrollingEnabled = false
        scrollingFrame.Active = true
        scrollingFrame.ScrollBarThickness = math.max(scrollingFrame.ScrollBarThickness, 4)
        TouchScrollRegistry[scrollingFrame] = true
        bindTouchScrollConnections()
    else
        scrollingFrame.ScrollingEnabled = true
        TouchScrollRegistry[scrollingFrame] = nil
    end
end

local function bindVerticalCanvas(scrollingFrame, listLayout, extraBottom, touchScrollEnabled)
    extraBottom = math.max(tonumber(extraBottom) or 0, 0)

    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
    scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
    registerTouchScrolling(scrollingFrame, touchScrollEnabled)

    local updateQueued = false
    local trackedObjects = setmetatable({}, { __mode = "k" })
    local trackedConnections = setmetatable({}, { __mode = "k" })

    local function readPaddingHeight(scale)
        local total = 0
        local logicalHeight = scrollingFrame.AbsoluteSize.Y / math.max(scale, 0.01)

        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if child:IsA("UIPadding") then
                total = total
                    + child.PaddingTop.Offset
                    + child.PaddingBottom.Offset
                    + (child.PaddingTop.Scale * logicalHeight)
                    + (child.PaddingBottom.Scale * logicalHeight)
            end
        end

        return total
    end

    local function calculateContentHeight()
        -- AbsoluteContentSize is reported in rendered pixels. CanvasPosition and
        -- CanvasSize offsets use the ScrollingFrame's logical, pre-UIScale units.
        -- On mobile the window is usually scaled down, so using the rendered size
        -- directly makes the canvas too short and prevents reaching the last item.
        local scale = effectiveGuiScale(scrollingFrame)
        local layoutHeight = math.ceil(listLayout.AbsoluteContentSize.Y / scale)
        local paddingHeight = math.ceil(readPaddingHeight(scale))
        return math.max(0, layoutHeight + paddingHeight + extraBottom)
    end

    local function applyCanvas()
        if not scrollingFrame.Parent or not listLayout.Parent then
            return
        end

        local contentHeight = calculateContentHeight()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)

        -- Use the same scale-aware calculation as the touch-scroll clamp so the
        -- visible bottom and the draggable bottom always match.
        local maxCanvasY = maxCanvasPositionY(scrollingFrame)
        local current = scrollingFrame.CanvasPosition
        local clampedY = math.clamp(current.Y, 0, maxCanvasY)

        if current.X ~= 0 or math.abs(current.Y - clampedY) > 0.5 then
            scrollingFrame.CanvasPosition = Vector2.new(0, clampedY)
        end
    end

    local function updateCanvas()
        if updateQueued then
            return
        end

        updateQueued = true
        task.defer(function()
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            updateQueued = false
            applyCanvas()
        end)
    end

    local function trackObject(object)
        if trackedObjects[object] then
            return
        end
        trackedObjects[object] = true

        local connections = {}
        trackedConnections[object] = connections

        local function watch(propertyName)
            local ok, signal = pcall(function()
                return object:GetPropertyChangedSignal(propertyName)
            end)
            if ok and signal then
                table.insert(connections, signal:Connect(updateCanvas))
            end
        end

        if object:IsA("GuiObject") then
            watch("AbsoluteSize")
            watch("Position")
            watch("Visible")
        end

        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            watch("Text")
            watch("TextBounds")
        end

        if object:IsA("UIListLayout") then
            watch("AbsoluteContentSize")
        elseif object:IsA("UIPadding") then
            watch("PaddingTop")
            watch("PaddingBottom")
        end

        table.insert(connections, object.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                local list = trackedConnections[object]
                if list then
                    for _, connection in ipairs(list) do
                        pcall(function()
                            connection:Disconnect()
                        end)
                    end
                end
                trackedConnections[object] = nil
                trackedObjects[object] = nil
                updateCanvas()
            end
        end))
    end

    trackObject(listLayout)
    for _, descendant in ipairs(scrollingFrame:GetDescendants()) do
        trackObject(descendant)
    end

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
    scrollingFrame:GetPropertyChangedSignal("Visible"):Connect(updateCanvas)
    scrollingFrame.ChildAdded:Connect(function(child)
        trackObject(child)
        for _, descendant in ipairs(child:GetDescendants()) do
            trackObject(descendant)
        end
        updateCanvas()
    end)
    scrollingFrame.DescendantAdded:Connect(function(descendant)
        trackObject(descendant)
        updateCanvas()
    end)
    scrollingFrame.DescendantRemoving:Connect(updateCanvas)

    updateCanvas()
    return updateCanvas
end

local function safeCallback(callback, ...)
    if type(callback) ~= "function" then
        return
    end

    local args = table.pack(...)
    task.spawn(function()
        local success, message = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        if not success then
            warn("[VoltzUI Callback Error] " .. tostring(message))
        end
    end)
end

local function getGuiParent()
    local success, result = pcall(function()
        if type(gethui) == "function" then
            return gethui()
        end

        if type(syn) == "table" and type(syn.protect_gui) == "function" then
            return CoreGui
        end

        if LocalPlayer then
            return LocalPlayer:WaitForChild("PlayerGui")
        end

        return CoreGui
    end)

    if success and result then
        return result
    end

    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    return CoreGui
end

local function protectGui(screenGui)
    pcall(function()
        if type(syn) == "table" and type(syn.protect_gui) == "function" then
            syn.protect_gui(screenGui)
        end
    end)
end

local function destroyPreviousVoltzUI()
    local checked = {}

    local function clean(parent)
        if not parent or checked[parent] then
            return
        end
        checked[parent] = true

        local existing = parent:FindFirstChild("VoltzUI")
        if existing then
            pcall(function()
                existing:Destroy()
            end)
        end
    end

    pcall(function()
        if type(gethui) == "function" then
            clean(gethui())
        end
    end)

    clean(CoreGui)

    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            clean(playerGui)
        end
    end
end

local function httpGet(url)
    local asyncSuccess, asyncResult = pcall(function()
        return game:HttpGetAsync(url)
    end)
    if asyncSuccess and type(asyncResult) == "string" and #asyncResult > 0 then
        return asyncResult
    end

    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and type(result) == "string" and #result > 0 then
        return result
    end

    error("Unable to download icon data: " .. tostring(result or asyncResult))
end

local function compileSource(source, chunkName)
    local loader = loadstring
    if type(loader) ~= "function" then
        error("loadstring is unavailable")
    end

    local chunk, compileError = loader(source, chunkName)
    if type(chunk) ~= "function" then
        error(compileError or "Source did not compile")
    end

    return chunk()
end

local function buildDirectIconProvider()
    local provider = {
        IconsType = "lucide",
        Icons = {},
    }

    local function parseIconString(iconString)
        if type(iconString) == "string" then
            local splitIndex = iconString:find(":")
            if splitIndex then
                return iconString:sub(1, splitIndex - 1), iconString:sub(splitIndex + 1)
            end
        end
        return nil, iconString
    end

    local function loadPack(packName)
        if provider.Icons[packName] then
            return provider.Icons[packName]
        end

        local url = ICON_PACK_URLS[packName]
        if not url then
            return nil
        end

        local pack = compileSource(httpGet(url), "@VoltzUI/Icons/" .. packName)
        if type(pack) ~= "table" then
            error("Icon pack '" .. tostring(packName) .. "' returned invalid data")
        end

        provider.Icons[packName] = pack
        return pack
    end

    function provider.SetIconsType(packName)
        if ICON_PACK_URLS[packName] then
            provider.IconsType = packName
            local success, message = pcall(loadPack, packName)
            if not success then
                warn("[VoltzUI] Could not preload icon pack '" .. tostring(packName) .. "': " .. tostring(message))
            end
        else
            warn("[VoltzUI] Unknown icon pack: " .. tostring(packName))
        end
    end

    function provider.Icon(icon, iconType, defaultFormat)
        defaultFormat = defaultFormat ~= false
        local explicitType, iconName = parseIconString(icon)
        local targetType = explicitType or iconType or provider.IconsType
        local iconSet = loadPack(targetType)

        if not iconSet or not iconName then
            return nil
        end

        if iconSet.Icons and iconSet.Icons[iconName] then
            local metadata = iconSet.Icons[iconName]
            local image = metadata.Image
            if iconSet.Spritesheets then
                image = iconSet.Spritesheets[tostring(metadata.Image)] or image
            end

            if type(image) == "number" then
                image = "rbxassetid://" .. tostring(image)
            end

            return {
                image,
                metadata,
            }
        end

        local directIcon = iconSet[iconName]
        if type(directIcon) == "number" then
            directIcon = "rbxassetid://" .. tostring(directIcon)
        end

        if type(directIcon) == "string" and directIcon:find("rbxassetid://", 1, true) then
            if defaultFormat then
                return {
                    directIcon,
                    {
                        ImageRectSize = Vector2.new(0, 0),
                        ImageRectPosition = Vector2.new(0, 0),
                    },
                }
            end
            return directIcon
        end

        return nil
    end

    function provider.Icon2(icon, iconType)
        return provider.Icon(icon, iconType, true)
    end

    function provider.GetIcon(icon, iconType)
        return provider.Icon(icon, iconType, false)
    end

    function provider.AddIcons(packName, iconData)
        if type(packName) ~= "string" or type(iconData) ~= "table" then
            error("AddIcons expects a pack name and icon table")
        end

        local pack = provider.Icons[packName] or {
            Icons = {},
            Spritesheets = {},
        }
        provider.Icons[packName] = pack

        for iconName, value in pairs(iconData) do
            if type(value) == "number" or type(value) == "string" then
                local image = type(value) == "number" and ("rbxassetid://" .. tostring(value)) or value
                pack.Icons[iconName] = {
                    Image = image,
                    ImageRectSize = Vector2.new(0, 0),
                    ImageRectPosition = Vector2.new(0, 0),
                }
                pack.Spritesheets[tostring(image)] = image
            elseif type(value) == "table" and value.Image then
                pack.Icons[iconName] = value
                local image = value.Image
                if type(image) == "number" then
                    image = "rbxassetid://" .. tostring(image)
                end
                pack.Spritesheets[tostring(value.Image)] = image
            end
        end
    end

    loadPack("lucide")
    return provider
end

local function loadExternalIcons()
    if VoltzUI.IconProvider then
        VoltzUI.IconsLoaded = true
        return VoltzUI.IconProvider
    end

    local success, provider = pcall(buildDirectIconProvider)
    if success and type(provider) == "table" then
        VoltzUI.IconProvider = provider
        VoltzUI.IconsLoaded = true
        return provider
    end

    VoltzUI.IconsLoaded = false
    warn("[VoltzUI] External icons could not be loaded: " .. tostring(provider))
    return nil
end

function VoltzUI:SetIconProvider(provider)
    assert(type(provider) == "table", "Icon provider must be a table")
    self.IconProvider = provider
    self.IconsLoaded = true
    return self
end

function VoltzUI:SetDefaultIconPack(packName)
    local provider = self.IconProvider or loadExternalIcons()
    if provider and provider.SetIconsType then
        provider.SetIconsType(packName)
    end
    return self
end

local function parseIconResult(provider, iconName, iconType)
    if not provider or not iconName or iconName == "" then
        return nil
    end

    local success, result = pcall(function()
        if provider.Icon2 then
            return provider.Icon2(iconName, iconType, true)
        elseif provider.Icon then
            return provider.Icon(iconName, iconType, true)
        elseif provider.GetIcon then
            return provider.GetIcon(iconName, iconType)
        end
        return nil
    end)

    if not success then
        return nil
    end

    if type(result) == "string" then
        return {
            Image = result,
            ImageRectSize = Vector2.new(0, 0),
            ImageRectPosition = Vector2.new(0, 0),
        }
    end

    if type(result) == "table" then
        if type(result[1]) == "string" then
            local metadata = result[2] or {}
            return {
                Image = result[1],
                ImageRectSize = metadata.ImageRectSize or Vector2.new(0, 0),
                ImageRectPosition = metadata.ImageRectPosition or Vector2.new(0, 0),
                Parts = metadata.Parts,
            }
        end

        if type(result.Image) == "string" then
            return result
        end
    end

    return nil
end

local function createIcon(parent, iconName, size, color, zIndex)
    local holder = create("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size or 18, size or 18),
        Parent = parent,
        ZIndex = zIndex or 1,
    })

    local iconObject = {
        Frame = holder,
        Layers = {},
    }

    function iconObject:SetColor(newColor)
        for _, layer in ipairs(self.Layers) do
            layer.ImageColor3 = newColor
        end
    end

    function iconObject:SetTransparency(value)
        for _, layer in ipairs(self.Layers) do
            layer.ImageTransparency = value
        end
    end

    function iconObject:Destroy()
        if self.Frame then
            self.Frame:Destroy()
        end
    end

    if not iconName or iconName == "" then
        holder.Visible = false
        return iconObject
    end

    local provider = VoltzUI.IconProvider or loadExternalIcons()
    local explicitType = type(iconName) == "string" and iconName:match("^([^:]+):") or nil
    local data = parseIconResult(provider, iconName, explicitType)

    if not data or not data.Image then
        holder.Visible = false
        return iconObject
    end

    local function addLayer(layerData)
        local image = create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = layerData.Image,
            ImageColor3 = color or Theme.TextMuted,
            ImageRectSize = layerData.ImageRectSize or Vector2.new(0, 0),
            ImageRectOffset = layerData.ImageRectPosition or Vector2.new(0, 0),
            ScaleType = Enum.ScaleType.Stretch,
            Parent = holder,
            ZIndex = zIndex or 1,
        })
        table.insert(iconObject.Layers, image)
    end

    addLayer(data)

    if type(data.Parts) == "table" then
        for _, partName in ipairs(data.Parts) do
            local partData = parseIconResult(provider, partName, explicitType)
            if partData and partData.Image then
                addLayer(partData)
            end
        end
    end

    return iconObject
end

local function dragify(handle, target, changedCallback, endedCallback, dragOptions)
    dragOptions = type(dragOptions) == "table" and dragOptions or {}

    local allowMouse = dragOptions.AllowMouse ~= false
    local allowTouch = dragOptions.AllowTouch ~= false
    local mouseThreshold = math.max(tonumber(dragOptions.MouseThreshold) or 0, 0)
    local touchThreshold = math.max(tonumber(dragOptions.TouchThreshold) or 10, 0)

    local pressed = false
    local dragging = false
    local dragInput
    local dragStart
    local startPosition
    local activeType

    local function inputAllowed(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            return allowMouse
        end
        if input.UserInputType == Enum.UserInputType.Touch then
            return allowTouch
        end
        return false
    end

    local function finishDrag()
        local didDrag = dragging
        pressed = false
        dragging = false
        dragInput = nil
        activeType = nil

        if didDrag and type(endedCallback) == "function" then
            endedCallback(target.Position)
        end
    end

    handle.InputBegan:Connect(function(input)
        if not inputAllowed(input) then
            return
        end

        pressed = true
        dragging = false
        dragInput = input.UserInputType == Enum.UserInputType.Touch and input or dragInput
        dragStart = input.Position
        startPosition = target.Position
        activeType = input.UserInputType

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                finishDrag()
            end
        end)
    end)

    handle.InputChanged:Connect(function(input)
        if activeType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        elseif activeType == Enum.UserInputType.Touch
            and input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not pressed or input ~= dragInput or not dragStart or not startPosition then
            return
        end

        local delta = input.Position - dragStart
        if not dragging then
            local threshold = activeType == Enum.UserInputType.Touch and touchThreshold or mouseThreshold
            if delta.Magnitude < threshold then
                return
            end
            dragging = true
        end

        target.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

        if type(changedCallback) == "function" then
            changedCallback(target.Position)
        end
    end)
end

local function themeKeyForColor(color)
    for _, key in ipairs(THEME_COLOR_KEYS) do
        if Theme[key] == color then
            return key
        end
    end
    return nil
end

local function bindHover(button, normalColor, hoverColor)
    local normalKey = themeKeyForColor(normalColor)
    local hoverKey = themeKeyForColor(hoverColor)

    button.MouseEnter:Connect(function()
        tween(button, 0.14, {
            BackgroundColor3 = hoverKey and Theme[hoverKey] or hoverColor,
        })
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.14, {
            BackgroundColor3 = normalKey and Theme[normalKey] or normalColor,
        })
    end)
end

local function createTextButton(properties)
    local button = create("TextButton", merge({
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Surface2,
        FontFace = fontFace("Medium"),
        TextColor3 = Theme.Text,
        TextSize = fontSize(13),
    }, properties))
    return button
end

local function createElementBase(section, options, height)
    options = merge({
        Title = "Element",
        Desc = nil,
        Icon = nil,
    }, options)

    local frame = create("Frame", {
        Name = options.Title,
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or (options.Desc and 72 or 60)),
        ClipsDescendants = true,
        Parent = section.Container,
    })
    corner(frame, 15)

    local leftOffset = 16
    local iconObject
    if options.Icon then
        iconObject = createIcon(frame, options.Icon, 18, Theme.TextMuted, 3)
        iconObject.Frame.Position = UDim2.new(0, 16, 0.5, -9)
        leftOffset = 46
    end

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, leftOffset, 0, options.Desc and 11 or 0),
        Size = UDim2.new(1, -(leftOffset + 112), options.Desc and 0 or 1, options.Desc and 24 or 0),
        FontFace = fontFace("Medium"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(14),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = frame,
        ZIndex = 3,
    })

    local description
    if options.Desc then
        description = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, leftOffset, 0, 38),
            Size = UDim2.new(1, -(leftOffset + 112), 0, 21),
            FontFace = fontFace("Regular"),
            Text = options.Desc,
            TextColor3 = Theme.TextMuted,
            TextTransparency = 0,
            TextSize = fontSize(12),
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = frame,
            ZIndex = 3,
        })
    end

    -- No UIStroke here: the previous outline was the "sunken border" visible around every card.
    frame.MouseEnter:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.SurfaceHover })
    end)

    frame.MouseLeave:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.Surface2 })
    end)

    local window = section.Tab and section.Tab.Window
    if window and options.TitleKey then
        window:_BindLocaleText(title, "Text", options.TitleKey, options.Title)
    end
    if window and description and options.DescKey then
        window:_BindLocaleText(description, "Text", options.DescKey, options.Desc)
    end

    return {
        Frame = frame,
        Title = title,
        Description = description,
        Icon = iconObject,
        Options = options,
    }
end

local SectionMethods = {}
SectionMethods.__index = SectionMethods

function SectionMethods:AddButton(options)
    options = merge({
        Title = "Button",
        Desc = nil,
        Icon = "mouse-pointer-click",
        Callback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local action = createTextButton({
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(1, -96, 0.5, -17),
        Size = UDim2.fromOffset(84, 34),
        Text = options.ButtonText or "Run",
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(action, 10)
    bindHover(action, Theme.Surface3, Theme.AccentDark)
    if options.ButtonTextKey then
        self.Tab.Window:_BindLocaleText(action, "Text", options.ButtonTextKey, options.ButtonText or "Run")
    end

    action.MouseButton1Click:Connect(function()
        tween(action, 0.08, { Size = UDim2.fromOffset(80, 32), Position = UDim2.new(1, -92, 0.5, -15) })
        task.delay(0.08, function()
            if action.Parent then
                tween(action, 0.1, { Size = UDim2.fromOffset(84, 34), Position = UDim2.new(1, -94, 0.5, -16) })
            end
        end)
        safeCallback(options.Callback)
    end)

    local controller = {}
    function controller:SetText(text)
        action.Text = tostring(text)
    end
    function controller:Fire()
        safeCallback(options.Callback)
    end
    function controller:Destroy()
        base.Frame:Destroy()
    end
    return controller
end

function SectionMethods:AddToggle(options)
    options = merge({
        Title = "Toggle",
        Desc = nil,
        Icon = "toggle-left",
        Default = false,
        Callback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local state = options.Default == true

    local toggleButton = createTextButton({
        BackgroundColor3 = state and Theme.Accent or Theme.Surface3,
        Position = UDim2.new(1, -64, 0.5, -14),
        Size = UDim2.fromOffset(50, 28),
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(toggleButton, 99)

    local knob = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = state and UDim2.new(1, -25, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
        Size = UDim2.fromOffset(20, 20),
        Parent = toggleButton,
        ZIndex = 5,
    })
    corner(knob, 99)

    local controller = {}

    function controller:Set(value, silent)
        state = value == true
        tween(toggleButton, 0.18, {
            BackgroundColor3 = state and Theme.Accent or Theme.Surface3,
        })
        tween(knob, 0.2, {
            Position = state and UDim2.new(1, -25, 0.5, -10) or UDim2.new(0, 4, 0.5, -10),
        }, Enum.EasingStyle.Back)

        if not silent then
            safeCallback(options.Callback, state)
        end
    end

    function controller:Get()
        return state
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    toggleButton.MouseButton1Click:Connect(function()
        controller:Set(not state)
    end)

    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "toggle")
end

function SectionMethods:AddSlider(options)
    options = merge({
        Title = "Slider",
        Desc = nil,
        Icon = "sliders-horizontal",
        Min = 0,
        Max = 100,
        Default = 50,
        Increment = 1,
        Suffix = "",
        Callback = function() end,
    }, options)

    options.Min = tonumber(options.Min) or 0
    options.Max = tonumber(options.Max) or 100
    options.Increment = math.max(tonumber(options.Increment) or 1, 0.0001)

    local base = createElementBase(self, options, options.Desc and 76 or 68)
    base.Title.Size = UDim2.new(1, -180, 0, 20)

    local value = math.clamp(tonumber(options.Default) or options.Min, options.Min, options.Max)
    local valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 10),
        Size = UDim2.fromOffset(86, 20),
        FontFace = fontFace("Medium"),
        Text = tostring(value) .. tostring(options.Suffix),
        TextColor3 = Theme.Accent,
        TextSize = fontSize(12),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = base.Frame,
        ZIndex = 4,
    })

    local bar = create("Frame", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 1, -19),
        Size = UDim2.new(1, -28, 0, 7),
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(bar, 99)

    local fill = create("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = bar,
        ZIndex = 5,
    })
    corner(fill, 99)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = bar,
        ZIndex = 6,
    })
    corner(knob, 99)
    stroke(knob, Theme.Accent, 0, 2)

    local dragging = false
    local controller = {}

    local function normalize(number)
        if options.Max == options.Min then
            return 0
        end
        return (number - options.Min) / (options.Max - options.Min)
    end

    local function roundToIncrement(number)
        local rounded = math.floor(((number - options.Min) / options.Increment) + 0.5) * options.Increment + options.Min
        local decimals = tostring(options.Increment):match("%.(%d+)")
        if decimals then
            local precision = #decimals
            local multiplier = 10 ^ precision
            rounded = math.floor(rounded * multiplier + 0.5) / multiplier
        end
        return math.clamp(rounded, options.Min, options.Max)
    end

    function controller:Set(newValue, silent)
        value = roundToIncrement(tonumber(newValue) or options.Min)
        local alpha = math.clamp(normalize(value), 0, 1)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. tostring(options.Suffix)
        if not silent then
            safeCallback(options.Callback, value)
        end
    end

    function controller:Get()
        return value
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    local function updateFromPosition(x)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        controller:Set(options.Min + ((options.Max - options.Min) * alpha))
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromPosition(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPosition(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    controller:Set(value, true)
    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "slider")
end

function SectionMethods:AddDropdown(options)
    options = merge({
        Title = "Dropdown",
        Desc = nil,
        Icon = "list-filter",
        Values = {},
        Default = nil,
        Multi = false,
        Callback = function() end,
    }, options)

    -- Dropdowns need a fixed header and a separate expandable list area.
    -- Keeping the title, icon and selector inside the animated outer frame
    -- can make them appear to shift when the outer height changes.
    local collapsedHeight = options.Desc and 72 or 60
    local base = createElementBase(self, options, collapsedHeight)

    local header = create("Frame", {
        Name = "DropdownHeader",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, collapsedHeight),
        Parent = base.Frame,
        ZIndex = 4,
    })

    -- Move every header object into the fixed-height header container.
    -- The outer card may grow, but this header never changes height.
    if base.Icon and base.Icon.Frame then
        base.Icon.Frame.Parent = header
        base.Icon.Frame.AnchorPoint = Vector2.new(0, 0)
        base.Icon.Frame.Position = UDim2.fromOffset(
            16,
            math.floor((collapsedHeight - base.Icon.Frame.Size.Y.Offset) / 2)
        )
    end

    if base.Title then
        base.Title.Parent = header
    end

    if base.Description then
        base.Description.Parent = header
    end

    local open = false
    local values = options.Values or {}
    local selected = options.Multi and {} or options.Default
    local optionButtons = {}

    if options.Multi and type(options.Default) == "table" then
        for _, item in ipairs(options.Default) do
            selected[item] = true
        end
    end

    local selector = createTextButton({
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(1, -170, 0, 10),
        Size = UDim2.fromOffset(156, 34),
        Parent = header,
        ZIndex = 5,
    })
    corner(selector, 10)

    local selectedLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        FontFace = fontFace("Regular"),
        Text = self.Tab.Window:T("SelectPlaceholder", "Select..."),
        TextColor3 = Theme.TextMuted,
        TextTransparency = 0.08,
        TextSize = fontSize(12),
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = selector,
        ZIndex = 6,
    })

    local arrow = createIcon(selector, "chevron-down", 14, Theme.TextMuted, 6)
    arrow.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Frame.Position = UDim2.new(1, -18, 0.5, 0)

    local list = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        Position = UDim2.new(0, 14, 0, collapsedHeight + 8),
        Size = UDim2.new(1, -28, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        Visible = false,
        Parent = base.Frame,
        ZIndex = 6,
    })

    local listLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })
    local refreshListCanvas = bindVerticalCanvas(list, listLayout, 0, self.Tab.Window.MobileTouchScroll)

    local controller = {}

    local function selectedText()
        if options.Multi then
            local names = {}
            for _, item in ipairs(values) do
                if selected[item] then
                    table.insert(names, tostring(item))
                end
            end
            if #names == 0 then
                return self.Tab.Window:T("SelectPlaceholder", "Select...")
            end
            return table.concat(names, ", ")
        end

        return selected ~= nil and tostring(selected)
            or self.Tab.Window:T("SelectPlaceholder", "Select...")
    end

    local function refreshVisuals()
        selectedLabel.Text = selectedText()
        local isEmpty = options.Multi and next(selected) == nil or (not options.Multi and selected == nil)
        selectedLabel.TextColor3 = isEmpty and Theme.TextMuted or Theme.Text

        for valueName, buttonData in pairs(optionButtons) do
            local isSelected = options.Multi and selected[valueName] == true or selected == valueName
            tween(buttonData.Button, 0.12, {
                BackgroundColor3 = isSelected and Theme.AccentDark or Theme.Surface3,
            })
            buttonData.Check.Frame.Visible = isSelected
        end
    end

    local function setOpen(value)
        open = value == true

        local visibleCount = math.min(#values, 5)
        local listHeight = visibleCount > 0
            and (visibleCount * 35 + math.max(visibleCount - 1, 0) * 5)
            or 0

        -- On touch devices VoltzUI uses its own CanvasPosition fallback.
        -- Re-enabling Roblox native scrolling here makes the dropdown and
        -- the parent page react to the same finger drag at the same time.
        local useMobileTouchFallback =
            self.Tab.Window.MobileTouchScroll == true
            and UserInputService.TouchEnabled

        list.Visible = open
        list.Active = open

        if useMobileTouchFallback then
            -- Keep native scrolling disabled. The nested dropdown remains in
            -- TouchScrollRegistry and wins over the parent page by ZIndex/area.
            list.ScrollingEnabled = false
        else
            -- Desktop and non-fallback environments can use native scrolling.
            list.ScrollingEnabled = open and #values > 5
        end

        if not open then
            -- Reopen from the top and prevent an old CanvasPosition from
            -- causing the list to jump or appear to contain fewer entries.
            list.CanvasPosition = Vector2.new(0, 0)
        end

        list.Size = UDim2.new(1, -28, 0, listHeight)

        tween(base.Frame, 0.2, {
            Size = UDim2.new(
                1,
                0,
                0,
                open and (collapsedHeight + listHeight + 18) or collapsedHeight
            ),
        }, Enum.EasingStyle.Quint)

        tween(arrow.Frame, 0.2, {
            Rotation = open and 180 or 0,
        }, Enum.EasingStyle.Quint)

        local function refreshDropdownScrolling()
            if not base.Frame or not base.Frame.Parent then
                return
            end

            refreshListCanvas()
            if self.Tab and self.Tab.RefreshScroll then
                self.Tab:RefreshScroll()
            end
        end

        -- AutomaticSize/tween updates can finish one or more frames later.
        -- Refresh immediately, next frame, and after the open/close tween.
        refreshDropdownScrolling()
        task.defer(refreshDropdownScrolling)
        task.delay(0.22, refreshDropdownScrolling)
    end

    local function rebuild()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        optionButtons = {}

        for index, valueName in ipairs(values) do
            local optionButton = createTextButton({
                BackgroundColor3 = Theme.Surface3,
                Size = UDim2.new(1, 0, 0, 35),
                LayoutOrder = index,
                Parent = list,
                ZIndex = 7,
            })
            corner(optionButton, 9)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                FontFace = fontFace("Regular"),
                Text = tostring(valueName),
                TextColor3 = Theme.Text,
                TextSize = fontSize(11),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = optionButton,
                ZIndex = 8,
            })

            local check = createIcon(optionButton, "check", 14, Theme.Text, 8)
            check.Frame.AnchorPoint = Vector2.new(1, 0.5)
            check.Frame.Position = UDim2.new(1, -10, 0.5, 0)
            check.Frame.Visible = false

            optionButtons[valueName] = {
                Button = optionButton,
                Check = check,
            }

            optionButton.MouseButton1Click:Connect(function()
                if options.Multi then
                    selected[valueName] = not selected[valueName]
                    refreshVisuals()
                    safeCallback(options.Callback, cloneTable(selected))
                    if controller._Commit then
                        controller:_Commit()
                    end
                else
                    selected = valueName
                    refreshVisuals()
                    setOpen(false)
                    safeCallback(options.Callback, selected)
                    if controller._Commit then
                        controller:_Commit()
                    end
                end
            end)
        end

        refreshVisuals()
        refreshListCanvas()
        if open then
            setOpen(true)
        end
    end

    function controller:Set(value, silent)
        if options.Multi then
            selected = {}
            if type(value) == "table" then
                for key, item in pairs(value) do
                    if type(key) == "number" then
                        selected[item] = true
                    elseif item == true then
                        selected[key] = true
                    end
                end
            end
        else
            selected = value
        end

        refreshVisuals()
        if not silent then
            safeCallback(options.Callback, options.Multi and cloneTable(selected) or selected)
        end
    end

    function controller:Get()
        return options.Multi and cloneTable(selected) or selected
    end

    function controller:SetValues(newValues)
        values = type(newValues) == "table" and newValues or {}
        rebuild()
    end

    function controller:Open()
        setOpen(true)
    end

    function controller:Close()
        setOpen(false)
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    selector.MouseButton1Click:Connect(function()
        setOpen(not open)
    end)

    self.Tab.Window:_RegisterLocaleUpdater(refreshVisuals)
    rebuild()
    return self.Tab.Window:_RegisterControl(
        self,
        options,
        controller,
        options.Default,
        options.Multi and "multi-dropdown" or "dropdown"
    )
end

function SectionMethods:AddInput(options)
    options = merge({
        Title = "Input",
        Desc = nil,
        Icon = "text-cursor-input",
        Placeholder = "Type here...",
        Default = "",
        Numeric = false,
        ClearOnFocus = false,
        Callback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local box = create("TextBox", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        ClearTextOnFocus = options.ClearOnFocus == true,
        FontFace = fontFace("Regular"),
        PlaceholderColor3 = Theme.TextDim,
        PlaceholderText = options.Placeholder,
        Position = UDim2.new(1, -190, 0.5, -16),
        Size = UDim2.fromOffset(176, 34),
        Text = tostring(options.Default or ""),
        TextColor3 = Theme.Text,
        TextSize = fontSize(12),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(box, 10)
    padding(box, 10, 10, 0, 0)
    if options.PlaceholderKey then
        self.Tab.Window:_BindLocaleText(box, "PlaceholderText", options.PlaceholderKey, options.Placeholder)
    end
    local boxStroke = stroke(box, Theme.Border, 0.16, 1)

    box.Focused:Connect(function()
        tween(boxStroke, 0.15, { Color = Theme.Accent, Transparency = 0 })
    end)

    box.FocusLost:Connect(function(enterPressed)
        tween(boxStroke, 0.15, { Color = Theme.Border, Transparency = 0.3 })
        safeCallback(options.Callback, options.Numeric and tonumber(box.Text) or box.Text, enterPressed)
    end)

    if options.Numeric then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local filtered = box.Text:gsub("[^%d%.%-]", "")
            if filtered ~= box.Text then
                box.Text = filtered
            end
        end)
    end

    local controller = {
        _Box = box,
    }
    function controller:Set(value, silent)
        box.Text = tostring(value or "")
        if not silent then
            safeCallback(options.Callback, options.Numeric and tonumber(box.Text) or box.Text, false)
        end
    end
    function controller:Get()
        return options.Numeric and tonumber(box.Text) or box.Text
    end
    function controller:Focus()
        box:CaptureFocus()
    end
    function controller:Destroy()
        base.Frame:Destroy()
    end
    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "input")
end

function SectionMethods:AddKeybind(options)
    options = merge({
        Title = "Keybind",
        Desc = nil,
        Icon = "keyboard",
        Default = Enum.KeyCode.RightShift,
        Callback = function() end,
        ChangedCallback = function() end,
    }, options)

    local base = createElementBase(self, options)
    local currentKey = options.Default
    local listening = false

    local keyButton = createTextButton({
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(1, -116, 0.5, -16),
        Size = UDim2.fromOffset(104, 34),
        Text = currentKey and currentKey.Name or self.Tab.Window:T("NoneText", "None"),
        Parent = base.Frame,
        ZIndex = 4,
    })
    corner(keyButton, 10)

    local controller = {}

    function controller:Set(keyCode, silent)
        if type(keyCode) == "string" then
            keyCode = Enum.KeyCode[keyCode]
        end
        currentKey = keyCode
        keyButton.Text = currentKey and currentKey.Name or self.Tab.Window:T("NoneText", "None")
        if not silent then
            safeCallback(options.ChangedCallback, currentKey)
        end
    end

    function controller:Get()
        return currentKey
    end

    function controller:Destroy()
        base.Frame:Destroy()
    end

    keyButton.MouseButton1Click:Connect(function()
        listening = true
        keyButton.Text = self.Tab.Window:T("PressKey", "Press a key...")
        tween(keyButton, 0.12, { BackgroundColor3 = Theme.AccentDark })
    end)

    self.Tab.Window:_RegisterLocaleUpdater(function()
        if listening then
            keyButton.Text = self.Tab.Window:T("PressKey", "Press a key...")
        elseif not currentKey then
            keyButton.Text = self.Tab.Window:T("NoneText", "None")
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                controller:Set(input.KeyCode)
                tween(keyButton, 0.12, { BackgroundColor3 = Theme.Surface3 })
            end
            return
        end

        if not gameProcessed and currentKey and input.KeyCode == currentKey then
            safeCallback(options.Callback, currentKey)
        end
    end)

    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "keybind")
end

function SectionMethods:AddParagraph(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Information",
        Content = "",
        Icon = "info",
        MinHeight = 86,
        MaxHeight = nil,
    }, options)

    local minHeight = math.max(tonumber(options.MinHeight) or 86, 72)
    local maxHeight = tonumber(options.MaxHeight)

    local frame = create("Frame", {
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, minHeight),
        AutomaticSize = Enum.AutomaticSize.None,
        ClipsDescendants = false,
        Parent = self.Container,
    })
    corner(frame, 15)
    padding(frame, 16, 16, 14, 14)

    local iconObject = createIcon(frame, options.Icon, 18, Theme.Accent, 3)
    iconObject.Frame.Position = UDim2.fromOffset(0, 1)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -30, 0, 25),
        FontFace = fontFace("Medium"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(14),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 3,
    })

    local content = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 33),
        Size = UDim2.new(1, -30, 0, fontSize(12) + 4),
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = fontFace("Regular"),
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextTransparency = 0,
        TextSize = fontSize(12),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame,
        ZIndex = 3,
    })

    local function updateHeight()
        task.defer(function()
            if not frame.Parent then
                return
            end

            local measured = math.max(
                math.ceil(content.TextBounds.Y),
                math.ceil(content.AbsoluteSize.Y),
                fontSize(12) + 4
            )
            local neededHeight = 33 + measured + 30
            local targetHeight = math.max(minHeight, neededHeight)

            if maxHeight and maxHeight > 0 then
                targetHeight = math.min(targetHeight, maxHeight)
                frame.ClipsDescendants = neededHeight > maxHeight
            else
                frame.ClipsDescendants = false
            end

            frame.Size = UDim2.new(1, 0, 0, targetHeight)
            if self.Tab and self.Tab.RefreshScroll then
                self.Tab:RefreshScroll()
            end
        end)
    end

    content:GetPropertyChangedSignal("TextBounds"):Connect(updateHeight)
    content:GetPropertyChangedSignal("Text"):Connect(updateHeight)
    local lastMeasuredWidth = 0
    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        -- Only width changes affect wrapping. Ignoring height changes prevents
        -- a resize feedback loop when the paragraph expands.
        local width = math.floor(frame.AbsoluteSize.X + 0.5)
        if width ~= lastMeasuredWidth then
            lastMeasuredWidth = width
            updateHeight()
        end
    end)

    frame.MouseEnter:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.SurfaceHover })
    end)

    frame.MouseLeave:Connect(function()
        tween(frame, 0.16, { BackgroundColor3 = Theme.Surface2 })
    end)

    local controller = {}
    function controller:SetTitle(text)
        title.Text = tostring(text)
    end
    function controller:SetContent(text)
        content.Text = tostring(text)
        updateHeight()
    end
    function controller:GetHeight()
        return frame.Size.Y.Offset
    end
    function controller:RefreshSize()
        updateHeight()
    end
    function controller:Destroy()
        frame:Destroy()
    end

    local window = self.Tab and self.Tab.Window
    if window and options.TitleKey then
        window:_BindLocaleText(title, "Text", options.TitleKey, options.Title)
    end
    if window and options.ContentKey then
        window:_BindLocaleText(content, "Text", options.ContentKey, options.Content)
    end

    updateHeight()
    return controller
end

function SectionMethods:AddDivider(value)
    local options
    if type(value) == "table" then
        options = value
    else
        options = { Text = value }
    end

    local text = options.Text
    local frame = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, text and 26 or 14),
        Parent = self.Container,
    })

    local line = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = frame,
    })

    if text then
        local label = create("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(0, 18),
            FontFace = fontFace("Regular"),
            Text = "  " .. tostring(text) .. "  ",
            TextColor3 = Theme.TextDim,
            TextSize = fontSize(11),
            Parent = frame,
            ZIndex = 2,
        })
        line.ZIndex = 1

        if options.LocaleKey then
            self.Tab.Window:_RegisterLocaleUpdater(function()
                label.Text = "  " .. self.Tab.Window:T(options.LocaleKey, text) .. "  "
            end)
        end
        return label
    end

    return line
end

local TabMethods = {}
TabMethods.__index = TabMethods

function TabMethods:RefreshScroll()
    if self.RefreshCanvas then
        self.RefreshCanvas()
    end
end

function TabMethods:AddSection(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Section",
        Desc = nil,
    }, options)

    local sectionFrame = create("Frame", {
        Name = options.Title,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Page,
    })

    local headerHeight = options.Desc and 54 or 38
    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -4, 0, 25),
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(14),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sectionFrame,
    })

    local description
    if options.Desc then
        description = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(2, 26),
            Size = UDim2.new(1, -4, 0, 21),
            FontFace = fontFace("Regular"),
            Text = options.Desc,
            TextColor3 = Theme.TextMuted,
            TextTransparency = 0,
            TextSize = fontSize(11),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sectionFrame,
        })
    end

    local container = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, headerHeight),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = sectionFrame,
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = container,
    })

    create("UIPadding", {
        PaddingBottom = UDim.new(0, 5),
        Parent = container,
    })

    local section = setmetatable({
        Frame = sectionFrame,
        Container = container,
        TitleLabel = title,
        DescriptionLabel = description,
        Title = options.Title,
        Tab = self,
    }, SectionMethods)

    if options.TitleKey then
        self.Window:_BindLocaleText(title, "Text", options.TitleKey, options.Title)
    end
    if description and options.DescKey then
        self.Window:_BindLocaleText(description, "Text", options.DescKey, options.Desc)
    end

    return section
end

function TabMethods:Select()
    self.Window:SelectTab(self)
end

function TabMethods:SetTitle(text)
    self.Title = tostring(text)
    self.ButtonLabel.Text = self.Title
    if self.Window.SelectedTab == self then
        self.Window.ActiveTitle.Text = self.Title
    end
end

function TabMethods:Destroy()
    self.Button:Destroy()
    self.Page:Destroy()

    for index, tab in ipairs(self.Window.Tabs) do
        if tab == self then
            table.remove(self.Window.Tabs, index)
            break
        end
    end

    if self.Window.SelectedTab == self then
        self.Window.SelectedTab = nil
        if self.Window.Tabs[1] then
            self.Window:SelectTab(self.Window.Tabs[1])
        end
    end
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods

function WindowMethods:T(key, fallback)
    return translate(self.LanguageName or ActiveLanguageName, key, fallback)
end

function WindowMethods:_RegisterLocaleUpdater(callback)
    if type(callback) ~= "function" then
        return nil
    end
    self._LocaleUpdaters = self._LocaleUpdaters or {}
    table.insert(self._LocaleUpdaters, callback)
    local ok, message = pcall(callback)
    if not ok then
        warn("[VoltzUI Locale] " .. tostring(message))
    end
    return callback
end

function WindowMethods:_BindLocaleText(instance, property, key, fallback)
    return self:_RegisterLocaleUpdater(function()
        if instance and instance.Parent then
            instance[property] = self:T(key, fallback)
        end
    end)
end

function WindowMethods:SetLanguage(languageSpec)
    local selected = resolveLanguage(languageSpec)
    self.LanguageName = selected
    ActiveLanguageName = selected
    VoltzUI.DefaultLanguage = selected

    for _, updater in ipairs(self._LocaleUpdaters or {}) do
        local ok, message = pcall(updater)
        if not ok then
            warn("[VoltzUI Locale] " .. tostring(message))
        end
    end
    return true, selected
end

function WindowMethods:GetLanguage()
    return self.LanguageName or ActiveLanguageName
end


function WindowMethods:_BuildFlag(section, options)
    local requested = options.Flag or options.Id
    local base = requested or table.concat({
        tostring(section.Tab.Title or "Tab"),
        tostring(section.Title or "Section"),
        tostring(options.Title or "Control"),
    }, ".")

    base = sanitizeName(base, "Control")
    local flag = base
    local index = 2
    while self.Controls[flag] do
        flag = base .. "_" .. tostring(index)
        index = index + 1
    end
    return flag
end

function WindowMethods:_QueueAutoSave()
    if not self.Config.Enabled
        or not self.Config.AutoSave
        or self._LoadingConfig
        or self._Initializing then
        return
    end

    self._SaveToken = (self._SaveToken or 0) + 1
    local token = self._SaveToken
    task.delay(self.Config.AutoSaveDelay, function()
        if self.ScreenGui and self.ScreenGui.Parent and token == self._SaveToken then
            self:SaveConfig()
        end
    end)
end

function WindowMethods:_StoreControl(flag, value)
    if not flag then
        return
    end

    self.Flags[flag] = deepClone(value)
    self:_QueueAutoSave()
end

function WindowMethods:_RegisterControl(section, options, controller, defaultValue, controlType)
    local flag = self:_BuildFlag(section, options)
    local originalSet = controller.Set
    local window = self

    controller.Flag = flag
    controller.Type = controlType

    function controller:Set(value, silent)
        originalSet(self, value, silent)
        window:_StoreControl(flag, self:Get())
    end

    function controller:_Commit()
        window:_StoreControl(flag, self:Get())
    end

    self.Controls[flag] = {
        Controller = controller,
        Default = deepClone(defaultValue),
        Save = options.Save ~= false,
        Type = controlType,
    }
    self.Flags[flag] = deepClone(controller:Get())

    if controller._Box then
        controller._Box:GetPropertyChangedSignal("Text"):Connect(function()
            if controller._Commit then
                controller:_Commit()
            end
        end)
    end

    local savedValues = self.LoadedConfig and self.LoadedConfig.Values
    if self.Config.AutoLoad and type(savedValues) == "table" and savedValues[flag] ~= nil then
        self._LoadingConfig = true
        controller:Set(deserializeValue(savedValues[flag]), false)
        self._LoadingConfig = false
    end

    return controller
end

function WindowMethods:SetAutoSave(value)
    self.Config.AutoSave = value == true
    if self.Config.AutoSave then
        self:_QueueAutoSave()
    end
end

function WindowMethods:SetConfigName(name)
    local path, safeName = buildConfigPath(self.Config.Folder, name or self.Config.FileName)
    self.Config.FileName = safeName
    self.Config.Path = path
    return safeName, path
end

function WindowMethods:GetConfigName()
    return self.Config.FileName
end

function WindowMethods:GetConfigList()
    local names = listConfigNames(self.Config.Folder)
    if self.Config.FileName and self.Config.FileName ~= "" then
        local found = false
        for _, item in ipairs(names) do
            if item == self.Config.FileName then
                found = true
                break
            end
        end
        if not found then
            table.insert(names, self.Config.FileName)
            table.sort(names, function(a, b)
                return tostring(a):lower() < tostring(b):lower()
            end)
        end
    end
    return names
end

function WindowMethods:RefreshConfigList()
    return self:GetConfigList()
end

function WindowMethods:GetAutoloadConfig()
    if self.Config.AutoloadName and self.Config.AutoloadName ~= "" then
        return self.Config.AutoloadName
    end

    local name = readAutoloadConfigName(self.Config)
    self.Config.AutoloadName = name
    return name
end

function WindowMethods:SetAutoloadConfig(configName)
    if not self.Config.Enabled then
        return false, "Config is disabled"
    end

    local configPath, safeName = buildConfigPath(self.Config.Folder, configName or self.Config.FileName)
    local existsOk, exists = pcall(isfile, configPath)
    if not existsOk or not exists then
        return false, self:T("SaveBeforeAutoload", "Save this config before setting it as autoload")
    end

    return writeAutoloadConfigName(self.Config, safeName)
end

function WindowMethods:ClearAutoloadConfig()
    return clearAutoloadConfigName(self.Config)
end

function WindowMethods:GetFlag(flag)
    return deepClone(self.Flags[flag])
end

function WindowMethods:SetFlag(flag, value, silent)
    local data = self.Controls[flag]
    if not data then
        return false, "Unknown flag: " .. tostring(flag)
    end

    data.Controller:Set(value, silent == true)
    return true
end

function WindowMethods:GetFlags()
    return deepClone(self.Flags)
end

function WindowMethods:SaveConfig(configName)
    if not self.Config.Enabled then
        return false, "Config is disabled"
    end
    if configName ~= nil then
        self:SetConfigName(configName)
    end

    if not fileSystemAvailable() then
        return false, "Executor does not support readfile/writefile/isfile"
    end

    ensureFolder(self.Config.Folder)

    local values = {}
    for flag, data in pairs(self.Controls) do
        if data.Save ~= false then
            values[flag] = serializeValue(data.Controller:Get())
        end
    end

    local windowData = {}
    if self.Config.SaveWindowPosition and not self.MobileMode then
        windowData.Position = serializeValue(self.Main.Position)
    end
    if self.Config.SaveSelectedTab and self.SelectedTab then
        windowData.SelectedTab = self.SelectedTab.Title
    end
    if self.Config.SaveMinimized then
        windowData.Minimized = self.Minimized
    end

    local payload = {
        Version = 1,
        LibraryVersion = VoltzUI.Version,
        Values = values,
        Window = windowData,
    }

    local encodeOk, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not encodeOk then
        return false, "Unable to encode config: " .. tostring(encoded)
    end

    local writeOk, writeError = pcall(writefile, self.Config.Path, encoded)
    if not writeOk then
        return false, "Unable to write config: " .. tostring(writeError)
    end

    self.LoadedConfig = payload
    return true, self.Config.Path
end

function WindowMethods:LoadConfig(configName)
    if configName ~= nil then
        self:SetConfigName(configName)
    end

    local data, readError = readConfigData(self.Config)
    if not data then
        return false, readError
    end

    self.LoadedConfig = data
    self._LoadingConfig = true

    local values = type(data.Values) == "table" and data.Values or {}
    for flag, controlData in pairs(self.Controls) do
        if values[flag] ~= nil then
            controlData.Controller:Set(deserializeValue(values[flag]), false)
        end
    end

    local windowData = type(data.Window) == "table" and data.Window or {}
    if self.Config.SaveWindowPosition and not self.MobileMode and windowData.Position then
        local position = deserializeValue(windowData.Position)
        if typeof(position) == "UDim2" then
            self.Main.Position = position
            if self.Shadow then
                self.Shadow.Position = UDim2.new(
                    position.X.Scale,
                    position.X.Offset,
                    position.Y.Scale,
                    position.Y.Offset + 8
                )
            end
        end
    end

    if self.Config.SaveSelectedTab and windowData.SelectedTab then
        self.PendingSelectedTab = tostring(windowData.SelectedTab)
        for _, tab in ipairs(self.Tabs) do
            if tab.Title == self.PendingSelectedTab then
                self:SelectTab(tab)
                break
            end
        end
    end

    if self.Config.SaveMinimized and windowData.Minimized ~= nil then
        self:Minimize(windowData.Minimized == true)
    end

    self._LoadingConfig = false
    return true, self.Config.Path
end

function WindowMethods:ResetConfig(saveAfterReset)
    self._LoadingConfig = true
    for flag, data in pairs(self.Controls) do
        if data.Save ~= false then
            data.Controller:Set(deepClone(data.Default), false)
            self.Flags[flag] = deepClone(data.Controller:Get())
        end
    end
    self._LoadingConfig = false

    if saveAfterReset ~= false then
        return self:SaveConfig()
    end
    return true
end

function WindowMethods:DeleteConfig(configName)
    if not self.Config.Enabled then
        return false, "Config is disabled"
    end
    if configName ~= nil then
        self:SetConfigName(configName)
    end
    if type(delfile) ~= "function" or type(isfile) ~= "function" then
        return false, "Executor does not support delfile/isfile"
    end

    local deletedName = self.Config.FileName
    local existsOk, exists = pcall(isfile, self.Config.Path)
    if existsOk and exists then
        local deleteOk, deleteError = pcall(delfile, self.Config.Path)
        if not deleteOk then
            return false, tostring(deleteError)
        end
    end

    if self:GetAutoloadConfig() == deletedName then
        self:ClearAutoloadConfig()
    end
    return true
end

function WindowMethods:SelectTab(tab)
    if self.SelectedTab == tab then
        return
    end

    for _, item in ipairs(self.Tabs) do
        local selected = item == tab
        item.Page.Visible = selected
        tween(item.Button, 0.15, {
            BackgroundColor3 = selected and Theme.Surface2 or Theme.Surface,
            BackgroundTransparency = selected and 0 or 1,
        })
        tween(item.Indicator, 0.15, {
            BackgroundTransparency = selected and 0 or 1,
        })
        item.ButtonLabel.TextColor3 = selected and Theme.Text or Theme.TextMuted
        if item.IconObject then
            item.IconObject:SetColor(selected and Theme.Accent or Theme.TextMuted)
        end
    end

    self.SelectedTab = tab
    self.ActiveTitle.Text = tab.Title
    self.ActiveDescription.Text = tab.Description or ""
    self.ActiveDescription.Visible = tab.Description ~= nil and tab.Description ~= ""

    task.defer(function()
        if tab and tab.Page and tab.Page.Parent and tab.RefreshScroll then
            tab:RefreshScroll()
        end
    end)

    if not self._LoadingConfig then
        self:_QueueAutoSave()
    end
end

function WindowMethods:AddTab(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Tab",
        Desc = nil,
        Icon = "circle",
    }, options)

    local button = createTextButton({
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = self.TabList,
        ZIndex = 5,
    })
    corner(button, 11)

    local indicator = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 22),
        Parent = button,
        ZIndex = 7,
    })
    corner(indicator, 99)

    local iconObject = createIcon(button, options.Icon, 17, Theme.TextMuted, 7)
    iconObject.Frame.Position = UDim2.new(0, 13, 0.5, -8)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(41, 0),
        Size = UDim2.new(1, -51, 1, 0),
        FontFace = fontFace("Medium"),
        Text = options.Title,
        TextColor3 = Theme.TextMuted,
        TextSize = fontSize(12),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
        ZIndex = 7,
    })

    local page = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollingEnabled = true,
        Position = UDim2.new(),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        Visible = false,
        Parent = self.PageContainer,
        ZIndex = 3,
    })
    padding(page, 2, 10, 0, 18)

    local pageLayout = create("UIListLayout", {
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    local refreshPageCanvas = bindVerticalCanvas(
        page,
        pageLayout,
        self.MobileMode and (self.MobileScrollBottomPadding or 28) or 8,
        self.MobileTouchScroll
    )

    local tab = setmetatable({
        Window = self,
        Title = options.Title,
        Description = options.Desc,
        Button = button,
        ButtonLabel = label,
        Indicator = indicator,
        IconObject = iconObject,
        Page = page,
        PageLayout = pageLayout,
        RefreshCanvas = refreshPageCanvas,
    }, TabMethods)

    table.insert(self.Tabs, tab)

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    button.MouseEnter:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 0.45 })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.12, { BackgroundTransparency = 1 })
        end
    end)

    if options.TitleKey then
        self:_RegisterLocaleUpdater(function()
            local translated = self:T(options.TitleKey, options.Title)
            tab.Title = translated
            label.Text = translated
            if self.SelectedTab == tab then
                self.ActiveTitle.Text = translated
            end
        end)
    end
    if options.DescKey then
        self:_RegisterLocaleUpdater(function()
            tab.Description = self:T(options.DescKey, options.Desc)
            if self.SelectedTab == tab then
                self.ActiveDescription.Text = tab.Description or ""
                self.ActiveDescription.Visible = tab.Description ~= nil and tab.Description ~= ""
            end
        end)
    end

    if self.PendingSelectedTab and self.PendingSelectedTab == tab.Title then
        self:SelectTab(tab)
    elseif not self.SelectedTab then
        self:SelectTab(tab)
    end

    return tab
end

function WindowMethods:RefreshScrolling(resetToTop)
    for _, tab in ipairs(self.Tabs) do
        if resetToTop == true and tab.Page then
            tab.Page.CanvasPosition = Vector2.new(0, 0)
        end
        if tab.RefreshScroll then
            tab:RefreshScroll()
        end
    end
end

function WindowMethods:SetVisible(value)
    self.Visible = value == true
    self.Root.Visible = self.Visible
    if self.MobileButton then
        self.MobileButton.Visible = not self.Visible
    end
end

function WindowMethods:Toggle()
    self:SetVisible(not self.Visible)
end

function WindowMethods:Minimize(value)
    if value == nil then
        value = not self.Minimized
    end

    local shouldMinimize = value == true
    if self.Minimized == shouldMinimize and not self._MinimizeTween then
        return
    end

    self.Minimized = shouldMinimize

    if self._MinimizeTween then
        pcall(function()
            self._MinimizeTween:Cancel()
        end)
        self._MinimizeTween = nil
    end

    if not shouldMinimize then
        self.Body.Visible = true
    end

    local headerHeight = self.HeaderHeight or 60
    local targetSize = shouldMinimize
        and UDim2.fromOffset(self.Size.X.Offset, headerHeight)
        or self.Size

    local mainTween = tween(self.Main, 0.24, {
        Size = targetSize,
    }, Enum.EasingStyle.Quint)
    self._MinimizeTween = mainTween

    if self.Shadow then
        tween(self.Shadow, 0.24, {
            Size = targetSize,
        }, Enum.EasingStyle.Quint)
    end

    mainTween.Completed:Connect(function()
        if self._MinimizeTween ~= mainTween then
            return
        end

        self._MinimizeTween = nil
        if self.Minimized then
            self.Body.Visible = false
        end
    end)

    if not self._LoadingConfig then
        self:_QueueAutoSave()
    end
end

function WindowMethods:Close()
    if self._Closing then
        return
    end

    self._Closing = true

    if self.InputConnection then
        self.InputConnection:Disconnect()
        self.InputConnection = nil
    end

    if self._MinimizeTween then
        pcall(function()
            self._MinimizeTween:Cancel()
        end)
        self._MinimizeTween = nil
    end

    if VoltzUI.ActiveWindow == self then
        VoltzUI.ActiveWindow = nil
    end

    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

function WindowMethods:SetToggleKey(keyCode)
    self.ToggleKey = keyCode
end

function WindowMethods:SetTheme(themeSpec)
    local name, newPalette = resolveTheme(themeSpec)
    local oldPalette = cloneTable(Theme)

    applyThemePalette(newPalette)
    recolorGuiTree(self.ScreenGui, oldPalette, newPalette)

    ActiveThemeName = name
    VoltzUI.DefaultTheme = name
    self.ThemeName = name
    return true, name
end

function WindowMethods:GetTheme()
    return self.ThemeName or ActiveThemeName, cloneTable(Theme)
end

function WindowMethods:_AddThemeControls(section, options)
    options = merge({
        Title = self:T("ThemeColorTitle", "Theme color"),
        Desc = self:T("ThemeColorDesc", "Change the interface accent instantly"),
        TitleKey = "ThemeColorTitle",
        DescKey = "ThemeColorDesc",
        Icon = "palette",
        Flag = "__VoltzTheme",
        Save = true,
    }, options)

    return section:AddDropdown({
        Title = options.Title,
        Desc = options.Desc,
        TitleKey = options.TitleKey,
        DescKey = options.DescKey,
        Icon = options.Icon,
        Values = VoltzUI:GetThemeNames(),
        Default = self.ThemeName or ActiveThemeName,
        Flag = options.Flag,
        Save = options.Save ~= false,
        Callback = function(value)
            local success, selectedName = self:SetTheme(value)
            if success then
                safeCallback(options.Callback, selectedName)
            end
        end,
    })
end

function WindowMethods:_AddLanguageControls(section, options)
    options = merge({
        Title = self:T("LanguageControlTitle", "Interface language"),
        Desc = self:T("LanguageControlDesc", "Change built-in VoltzUI text instantly"),
        TitleKey = "LanguageControlTitle",
        DescKey = "LanguageControlDesc",
        Icon = "languages",
        Flag = "__VoltzLanguage",
        Save = true,
    }, options)

    return section:AddDropdown({
        Title = options.Title,
        Desc = options.Desc,
        TitleKey = options.TitleKey,
        DescKey = options.DescKey,
        Icon = options.Icon,
        Values = VoltzUI:GetLanguageNames(),
        Default = self.LanguageName or ActiveLanguageName,
        Flag = options.Flag,
        Save = options.Save ~= false,
        Callback = function(value)
            local success, selectedName = self:SetLanguage(value)
            if success then
                safeCallback(options.Callback, selectedName)
            end
        end,
    })
end

function WindowMethods:AddThemeSection(tab, options)
    options = options or {}
    local customTitle = options.Title ~= nil
    local customDesc = options.Desc ~= nil
    options = merge({
        Title = self:T("AppearanceTitle", "Appearance"),
        Desc = self:T("AppearanceDesc", "Choose a color preset for the interface"),
    }, options)

    local section = tab:AddSection({
        Title = options.Title,
        Desc = options.Desc,
        TitleKey = customTitle and options.TitleKey or "AppearanceTitle",
        DescKey = customDesc and options.DescKey or "AppearanceDesc",
    })

    self:_AddThemeControls(section, {
        Title = options.ControlTitle or self:T("ThemeColorTitle", "Theme color"),
        Desc = options.ControlDesc or self:T("ThemeColorDesc", "Change the interface accent instantly"),
        TitleKey = options.ControlTitle and options.ControlTitleKey or "ThemeColorTitle",
        DescKey = options.ControlDesc and options.ControlDescKey or "ThemeColorDesc",
        Icon = options.Icon or "palette",
        Flag = options.Flag or "__VoltzTheme",
        Save = options.Save ~= false,
        Callback = options.Callback,
    })
    return section
end

function WindowMethods:AddLanguageSection(tab, options)
    options = options or {}
    local customTitle = options.Title ~= nil
    local customDesc = options.Desc ~= nil
    options = merge({
        Title = self:T("LanguageSectionTitle", "Language"),
        Desc = self:T("LanguageSectionDesc", "Choose the interface language"),
    }, options)

    local section = tab:AddSection({
        Title = options.Title,
        Desc = options.Desc,
        TitleKey = customTitle and options.TitleKey or "LanguageSectionTitle",
        DescKey = customDesc and options.DescKey or "LanguageSectionDesc",
    })

    self:_AddLanguageControls(section, {
        Title = options.ControlTitle or self:T("LanguageControlTitle", "Interface language"),
        Desc = options.ControlDesc or self:T("LanguageControlDesc", "Change built-in VoltzUI text instantly"),
        TitleKey = options.ControlTitle and options.ControlTitleKey or "LanguageControlTitle",
        DescKey = options.ControlDesc and options.ControlDescKey or "LanguageControlDesc",
        Icon = options.Icon or "languages",
        Flag = options.Flag or "__VoltzLanguage",
        Save = options.Save ~= false,
        Callback = options.Callback,
    })
    return section
end

function WindowMethods:Notify(options)
    if type(options) == "string" then
        options = { Title = options }
    end

    options = merge({
        Title = "Notification",
        Content = "",
        Duration = 4,
        Icon = "bell",
        Type = "Info",
    }, options)

    local accent = Theme.Accent
    if options.Type == "Success" then
        accent = Theme.Success
    elseif options.Type == "Warning" then
        accent = Theme.Warning
    elseif options.Type == "Error" or options.Type == "Danger" then
        accent = Theme.Danger
    end

    local card = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(300, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.NotificationList,
        ZIndex = 100,
    })
    corner(card, 12)
    stroke(card, Theme.Border, 0.14, 1)
    padding(card, 14, 14, 12, 12)

    local iconObject = createIcon(card, options.Icon, 18, accent, 102)
    iconObject.Frame.Position = UDim2.fromOffset(0, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -28, 0, 20),
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(15),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
        ZIndex = 102,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 25),
        Size = UDim2.new(1, -28, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = fontFace("Regular"),
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextSize = fontSize(12),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
        ZIndex = 102,
    })

    card.BackgroundTransparency = 1
    card.Position = UDim2.fromOffset(40, 0)
    tween(card, 0.25, { BackgroundTransparency = 0, Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)

    task.delay(math.max(tonumber(options.Duration) or 4, 0.5), function()
        if not card.Parent then
            return
        end
        tween(card, 0.2, { BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 0) })
        task.delay(0.22, function()
            if card.Parent then
                card:Destroy()
            end
        end)
    end)
end

function WindowMethods:AddConfigSection(tab, options)
    options = options or {}
    local customTitle = options.Title ~= nil
    local customDesc = options.Desc ~= nil
    options = merge({
        Title = self:T("ConfigurationTitle", "Configuration"),
        Desc = self:T("ConfigurationDesc", "Save, load and manage multiple VoltzUI configs"),
        IncludeLanguage = true,
        IncludeTheme = true,
    }, options)

    local section = tab:AddSection({
        Title = options.Title,
        Desc = options.Desc,
        TitleKey = customTitle and options.TitleKey or "ConfigurationTitle",
        DescKey = customDesc and options.DescKey or "ConfigurationDesc",
    })

    if options.IncludeLanguage ~= false then
        self:_AddLanguageControls(section, {
            Title = options.LanguageTitle or self:T("LanguageControlTitle", "Interface language"),
            Desc = options.LanguageDesc or self:T("LanguageControlDesc", "Change built-in VoltzUI text instantly"),
            TitleKey = options.LanguageTitle and options.LanguageTitleKey or "LanguageControlTitle",
            DescKey = options.LanguageDesc and options.LanguageDescKey or "LanguageControlDesc",
            Icon = options.LanguageIcon or "languages",
            Flag = "__VoltzLanguage",
            Save = true,
        })
    end

    if options.IncludeTheme ~= false then
        self:_AddThemeControls(section, {
            Title = options.ThemeTitle or self:T("ThemeColorTitle", "Theme color"),
            Desc = options.ThemeDesc or self:T("ThemeColorDesc", "Choose from built-in color presets"),
            TitleKey = options.ThemeTitle and options.ThemeTitleKey or "ThemeColorTitle",
            DescKey = options.ThemeDesc and options.ThemeDescKey or "ThemeColorDesc",
            Icon = "palette",
            Flag = "__VoltzTheme",
            Save = true,
        })
    end

    if options.IncludeLanguage ~= false or options.IncludeTheme ~= false then
        section:AddDivider({
            Text = self:T("ConfigFiles", "Config files"),
            LocaleKey = "ConfigFiles",
        })
    end

    local function configStatusText()
        if not self.Config.Enabled then
            return self:T("ConfigEnableHint", "Enable Config in CreateWindow to save settings.")
        end

        local autoloadName = self:GetAutoloadConfig()
        return self:T("FolderLabel", "Folder") .. ": " .. self.Config.Folder
            .. "\n" .. self:T("ActiveLabel", "Active") .. ": " .. self.Config.FileName
            .. "\n" .. self:T("AutoloadLabel", "Autoload") .. ": "
            .. tostring(autoloadName or self:T("NoAutoload", "None"))
    end

    local status = section:AddParagraph({
        Title = self.Config.Enabled
            and self:T("ConfigReady", "Config ready")
            or self:T("ConfigDisabled", "Config disabled"),
        Content = configStatusText(),
        Icon = self.Config.Enabled and "database" or "circle-off",
    })

    self:_RegisterLocaleUpdater(function()
        status:SetTitle(self.Config.Enabled
            and self:T("ConfigReady", "Config ready")
            or self:T("ConfigDisabled", "Config disabled"))
        status:SetContent(configStatusText())
    end)

    local configNameInput
    local configListDropdown

    local function refreshStatus(titleText, contentText)
        status:SetTitle(titleText)
        status:SetContent(contentText)
    end

    local function showResult(titleKey, fallbackTitle, success, message)
        local title = self:T(titleKey, fallbackTitle)
        local detail = tostring(message or "Done")
        if self.Config.Enabled then
            local autoloadName = self:GetAutoloadConfig()
            detail = detail
                .. "\n" .. self:T("ActiveLabel", "Active") .. ": " .. self.Config.FileName
                .. "\n" .. self:T("AutoloadLabel", "Autoload") .. ": "
                .. tostring(autoloadName or self:T("NoAutoload", "None"))
        end
        refreshStatus(success and title or (title .. " - Error"), detail)
        self:Notify({
            Title = title,
            Content = tostring(message or "Done"),
            Type = success and "Success" or "Error",
            Icon = success and "circle-check" or "circle-x",
        })
    end

    local function currentTypedName()
        local raw = configNameInput and configNameInput:Get() or self.Config.FileName
        return sanitizeName(raw, self.Config.FileName or "settings")
    end

    local function refreshConfigDropdown(selectName)
        if not configListDropdown then
            return
        end
        local names = self:RefreshConfigList()
        if #names == 0 and currentTypedName() ~= "" then
            names = { currentTypedName() }
        end
        configListDropdown:SetValues(names)
        local target = selectName or self.Config.FileName or names[1]
        if target then
            configListDropdown:Set(target, true)
        end
    end

    configListDropdown = section:AddDropdown({
        Title = self:T("SavedConfigsTitle", "Saved configs"),
        Desc = self:T("SavedConfigsDesc", "Choose a config file from your saved list"),
        TitleKey = "SavedConfigsTitle",
        DescKey = "SavedConfigsDesc",
        Icon = "folder-open",
        Values = self:RefreshConfigList(),
        Default = self.Config.FileName,
        Save = false,
        Callback = function(value)
            if value and value ~= "" then
                self:SetConfigName(value)
                if configNameInput then
                    configNameInput:Set(value, true)
                end
                refreshStatus(self:T("ConfigSelected", "Config selected"), configStatusText())
            end
        end,
    })

    configNameInput = section:AddInput({
        Title = self:T("ConfigNameTitle", "Config name"),
        Desc = self:T("ConfigNameDesc", "Type the name you want to save or load as"),
        TitleKey = "ConfigNameTitle",
        DescKey = "ConfigNameDesc",
        Icon = "text-cursor-input",
        Default = self.Config.FileName,
        Placeholder = self:T("ConfigNamePlaceholder", "example_config"),
        PlaceholderKey = "ConfigNamePlaceholder",
        Save = false,
        Callback = function(inputText)
            local name = sanitizeName(inputText, self.Config.FileName or "settings")
            self:SetConfigName(name)
            refreshStatus(self:T("ConfigSelected", "Config selected"), configStatusText())
        end,
    })

    section:AddButton({
        Title = self:T("SaveConfigTitle", "Save config"),
        Desc = self:T("SaveConfigDesc", "Save the current values into the typed config name"),
        TitleKey = "SaveConfigTitle",
        DescKey = "SaveConfigDesc",
        Icon = "save",
        ButtonText = self:T("SaveButton", "Save"),
        ButtonTextKey = "SaveButton",
        Callback = function()
            local name = currentTypedName()
            local success, message = self:SaveConfig(name)
            if success then
                if configNameInput then
                    configNameInput:Set(self.Config.FileName, true)
                end
                refreshConfigDropdown(self.Config.FileName)
            end
            showResult("ConfigSaved", "Config saved", success, message)
        end,
    })

    section:AddButton({
        Title = self:T("LoadConfigTitle", "Load config"),
        Desc = self:T("LoadConfigDesc", "Load the selected config from the dropdown"),
        TitleKey = "LoadConfigTitle",
        DescKey = "LoadConfigDesc",
        Icon = "download",
        ButtonText = self:T("LoadButton", "Load"),
        ButtonTextKey = "LoadButton",
        Callback = function()
            local selected = configListDropdown and configListDropdown:Get() or currentTypedName()
            local success, message = self:LoadConfig(selected)
            if success then
                if configNameInput then
                    configNameInput:Set(self.Config.FileName, true)
                end
                refreshConfigDropdown(self.Config.FileName)
            end
            showResult("ConfigLoaded", "Config loaded", success, message)
        end,
    })

    section:AddButton({
        Title = self:T("SetAutoloadTitle", "Set as autoload"),
        Desc = self:T("SetAutoloadDesc", "Load the selected config automatically next time the script runs"),
        TitleKey = "SetAutoloadTitle",
        DescKey = "SetAutoloadDesc",
        Icon = "pin",
        ButtonText = self:T("SetAutoloadButton", "Set"),
        ButtonTextKey = "SetAutoloadButton",
        Callback = function()
            local selected = configListDropdown and configListDropdown:Get() or currentTypedName()
            local success, message = self:SetAutoloadConfig(selected)
            if success then
                self:SetConfigName(selected)
                if configNameInput then
                    configNameInput:Set(self.Config.FileName, true)
                end
                refreshConfigDropdown(self.Config.FileName)
            end
            showResult("AutoloadSet", "Autoload config set", success, message)
        end,
    })

    section:AddButton({
        Title = self:T("ClearAutoloadTitle", "Clear autoload"),
        Desc = self:T("ClearAutoloadDesc", "Stop automatically loading a named config on startup"),
        TitleKey = "ClearAutoloadTitle",
        DescKey = "ClearAutoloadDesc",
        Icon = "pin-off",
        ButtonText = self:T("ClearAutoloadButton", "Clear"),
        ButtonTextKey = "ClearAutoloadButton",
        Callback = function()
            local success, message = self:ClearAutoloadConfig()
            showResult("AutoloadCleared", "Autoload cleared", success, message)
        end,
    })

    section:AddButton({
        Title = self:T("RefreshConfigTitle", "Refresh list"),
        Desc = self:T("RefreshConfigDesc", "Reload the dropdown from files inside your config folder"),
        TitleKey = "RefreshConfigTitle",
        DescKey = "RefreshConfigDesc",
        Icon = "refresh-cw",
        ButtonText = self:T("RefreshButton", "Refresh"),
        ButtonTextKey = "RefreshButton",
        Callback = function()
            refreshConfigDropdown(self.Config.FileName)
            showResult("ConfigListRefreshed", "Config list refreshed", true, self.Config.Folder)
        end,
    })

    section:AddButton({
        Title = self:T("DeleteConfigTitle", "Delete config"),
        Desc = self:T("DeleteConfigDesc", "Delete the selected config file from disk"),
        TitleKey = "DeleteConfigTitle",
        DescKey = "DeleteConfigDesc",
        Icon = "trash-2",
        ButtonText = self:T("DeleteButton", "Delete"),
        ButtonTextKey = "DeleteButton",
        Callback = function()
            local selected = configListDropdown and configListDropdown:Get() or currentTypedName()
            self:Confirm({
                Title = self:T("DeleteConfigTitle", "Delete config"),
                Content = "Delete config '" .. tostring(selected) .. "'?",
                ConfirmText = self:T("DeleteButton", "Delete"),
                Danger = true,
                Callback = function(confirmed)
                    if not confirmed then return end
                    local success, message = self:DeleteConfig(selected)
                    if success then refreshConfigDropdown(currentTypedName()) end
                    showResult("ConfigDeleted", "Config deleted", success, message)
                end,
            })
        end,
    })

    section:AddButton({
        Title = self:T("ResetDefaultsTitle", "Reset defaults"),
        Desc = self:T("ResetDefaultsDesc", "Restore all saved controls to their default values"),
        TitleKey = "ResetDefaultsTitle",
        DescKey = "ResetDefaultsDesc",
        Icon = "rotate-ccw",
        ButtonText = self:T("ResetButton", "Reset"),
        ButtonTextKey = "ResetButton",
        Callback = function()
            self:Confirm({
                Title = self:T("ResetDefaultsTitle", "Reset defaults"),
                Content = self:T("ConfirmQuestion", "Are you sure you want to continue?"),
                ConfirmText = self:T("ResetButton", "Reset"),
                Danger = true,
                Callback = function(confirmed)
                    if not confirmed then return end
                    local success, message = self:ResetConfig(false)
                    showResult("DefaultsRestored", "Defaults restored", success, message)
                end,
            })
        end,
    })

    refreshConfigDropdown(self.Config.FileName)
    return section
end

function WindowMethods:Destroy()
    self:Close()
end

function VoltzUI:CreateWindow(options)
    options = merge({
        Title = "Voltz UI",
        Subtitle = "Clean Roblox Interface",
        Icon = "sparkles",
        Size = UDim2.fromOffset(690, 470),
        ToggleKey = Enum.KeyCode.RightShift,
        MobileButton = true,
        MobileResponsive = true,
        MobileTouchScroll = true,
        -- Mobile input blocking is embedded in the library and enabled
        -- automatically on touch devices. No CreateWindow option is required.
        -- Touch dragging is disabled by default so a swipe used for scrolling
        -- cannot move the entire window on phones/tablets.
        MobileDraggable = false,
        MobileMargin = 12,
        MobileSidebarWidth = 150,
        MobileScrollBottomPadding = 28,
        Acrylic = false,
        Font = "NotoSansThai",
        Language = VoltzUI.DefaultLanguage or "English",
        Theme = VoltzUI.DefaultTheme or "Ocean Blue",
        HeaderHeight = 60,
        NotificationPosition = "BottomRight",
        Config = {
            Enabled = false,
        },
    }, options)

    local mobileMode = options.MobileResponsive ~= false and UserInputService.TouchEnabled
    local mobileTouchScroll = options.MobileTouchScroll ~= false and UserInputService.TouchEnabled
    local mobileDraggable = options.MobileDraggable == true

    self:SetFont(options.Font or "NotoSansThai")
    if options.FontScale ~= nil then
        self:SetFontScale(options.FontScale)
    end

    local initialLanguageName = resolveLanguage(options.Language)
    ActiveLanguageName = initialLanguageName
    self.DefaultLanguage = initialLanguageName

    local initialThemeName, initialThemePalette = resolveTheme(options.Theme)
    applyThemePalette(initialThemePalette)
    ActiveThemeName = initialThemeName
    self.DefaultTheme = initialThemeName

    local config = normalizeConfigOptions(options.Config)
    local loadedConfig = nil
    if config.Enabled and config.AutoLoad then
        local autoloadName = readAutoloadConfigName(config)
        if autoloadName then
            local path, safeName = buildConfigPath(config.Folder, autoloadName)
            config.FileName = safeName
            config.Path = path
            config.AutoloadName = safeName
        end
        loadedConfig = readConfigData(config)
    end

    local initialPosition = UDim2.fromScale(0.5, 0.5)
    local initialWindowData = loadedConfig and loadedConfig.Window
    if not mobileMode
        and config.SaveWindowPosition
        and type(initialWindowData) == "table"
        and initialWindowData.Position then
        local savedPosition = deserializeValue(initialWindowData.Position)
        if typeof(savedPosition) == "UDim2" then
            initialPosition = savedPosition
        end
    end

    loadExternalIcons()

    -- Clear stale windows from gethui/CoreGui/PlayerGui before creating a new one.
    -- This prevents an older build from remaining visible after a loader error.
    destroyPreviousVoltzUI()

    local screenGui = create("ScreenGui", {
        Name = "VoltzUI",
        DisplayOrder = 999,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    protectGui(screenGui)
    screenGui.Parent = getGuiParent()

    local root = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = screenGui,
    })

    -- The old offset black shadow created a visible square/edge outside
    -- the rounded window. Keep a transparent placeholder so existing
    -- window methods stay compatible without drawing that edge.
    local shadow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = initialPosition,
        Size = options.Size,
        Visible = false,
        Parent = root,
        ZIndex = 1,
    })

    local main = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = initialPosition,
        Size = options.Size,
        ClipsDescendants = true,
        Parent = root,
        ZIndex = 2,
    })
    corner(main, 10)

    local uiScale = create("UIScale", {
        Scale = 1,
        Parent = main,
    })
    local shadowScale = create("UIScale", {
        Scale = 1,
        Parent = shadow,
    })

    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        local viewport = camera.ViewportSize
        local margin = mobileMode and math.max(tonumber(options.MobileMargin) or 12, 4) or 20
        local insetTopLeft = Vector2.new(0, 0)
        local insetBottomRight = Vector2.new(0, 0)

        if mobileMode then
            pcall(function()
                insetTopLeft, insetBottomRight = GuiService:GetGuiInset()
            end)
        end

        local availableWidth = math.max(
            viewport.X - insetTopLeft.X - insetBottomRight.X - (margin * 2),
            1
        )
        local availableHeight = math.max(
            viewport.Y - insetTopLeft.Y - insetBottomRight.Y - (margin * 2),
            1
        )
        local baseWidth = math.max(options.Size.X.Offset, 1)
        local baseHeight = math.max(options.Size.Y.Offset, 1)
        local scale = math.min(1, availableWidth / baseWidth, availableHeight / baseHeight)

        uiScale.Scale = scale
        shadowScale.Scale = scale

        if mobileMode then
            local centerOffsetX = (insetTopLeft.X - insetBottomRight.X) * 0.5
            local centerOffsetY = (insetTopLeft.Y - insetBottomRight.Y) * 0.5
            local centeredPosition = UDim2.new(0.5, centerOffsetX, 0.5, centerOffsetY)
            main.Position = centeredPosition
            shadow.Position = centeredPosition
        end

        if VoltzUI.ActiveWindow
            and VoltzUI.ActiveWindow.Main == main
            and type(VoltzUI.ActiveWindow.RefreshScrolling) == "function" then
            task.defer(function()
                if VoltzUI.ActiveWindow and VoltzUI.ActiveWindow.Main == main then
                    VoltzUI.ActiveWindow:RefreshScrolling(false)
                end
            end)
        end
    end

    updateScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    local headerHeight = math.max(tonumber(options.HeaderHeight) or 60, 54)
    local topbar = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, headerHeight),
        Parent = main,
        ZIndex = 5,
    })
    corner(topbar, 10)

    -- Keep the lower edge square without mixing a different gradient/color band.
    create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = topbar,
        ZIndex = 5,
    })

    -- A subtle separator is cleaner than the old solid line.
    create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = topbar,
        ZIndex = 6,
    })

    local logoBox = create("Frame", {
        BackgroundColor3 = Theme.AccentDark,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 13),
        Size = UDim2.fromOffset(34, 34),
        Parent = topbar,
        ZIndex = 7,
    })
    corner(logoBox, 11)
    local logo = createIcon(logoBox, options.Icon, 18, Color3.fromRGB(255, 255, 255), 8)
    logo.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Frame.Position = UDim2.fromScale(0.5, 0.5)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(60, 8),
        Size = UDim2.new(1, -178, 0, 24),
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(15),
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
        ZIndex = 7,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(60, 31),
        Size = UDim2.new(1, -178, 0, 18),
        FontFace = fontFace("Regular"),
        Text = options.Subtitle,
        TextColor3 = Theme.TextDim,
        TextSize = fontSize(10),
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
        ZIndex = 7,
    })

    local minimizeButton = createTextButton({
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -90, 0, 13),
        Size = UDim2.fromOffset(34, 34),
        Parent = topbar,
        ZIndex = 8,
    })
    corner(minimizeButton, 10)
    local minimizeIcon = createIcon(minimizeButton, "minus", 15, Theme.TextMuted, 9)
    minimizeIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    minimizeIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
    bindHover(minimizeButton, Theme.Surface2, Theme.Surface3)

    local closeButton = createTextButton({
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -48, 0, 13),
        Size = UDim2.fromOffset(34, 34),
        Parent = topbar,
        ZIndex = 8,
    })
    corner(closeButton, 10)
    local closeIcon = createIcon(closeButton, "x", 15, Theme.TextMuted, 9)
    closeIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
    closeButton.MouseEnter:Connect(function()
        tween(closeButton, 0.14, { BackgroundColor3 = Theme.Danger })
        closeIcon:SetColor(Color3.fromRGB(255, 255, 255))
    end)
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, 0.14, { BackgroundColor3 = Theme.Surface2 })
        closeIcon:SetColor(Theme.TextMuted)
    end)

    local body = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, headerHeight),
        Size = UDim2.new(1, 0, 1, -headerHeight),
        Parent = main,
        ZIndex = 3,
    })

    local sidebarWidth = mobileMode
        and math.clamp(tonumber(options.MobileSidebarWidth) or 150, 132, 176)
        or 176

    local sidebar = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        Parent = body,
        ZIndex = 4,
    })
    corner(sidebar, 10)

    -- Keep only the outer bottom-left corner rounded. The top and right edges
    -- are internal joins, so these fills keep those joins perfectly square.
    create("Frame", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = sidebar,
        ZIndex = 4,
    })

    create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        Parent = sidebar,
        ZIndex = 4,
    })

    create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Parent = sidebar,
        ZIndex = 5,
    })

    local navigationLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 12),
        Size = UDim2.new(1, -28, 0, 18),
        FontFace = fontFace("Medium"),
        Text = translate(initialLanguageName, "Navigation", "NAVIGATION"),
        TextColor3 = Theme.TextDim,
        TextSize = fontSize(10),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebar,
        ZIndex = 5,
    })

    local tabList = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        Position = UDim2.fromOffset(10, 38),
        Size = UDim2.new(1, -20, 1, -50),
        ScrollBarThickness = 0,
        Parent = sidebar,
        ZIndex = 5,
    })
    local tabListLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList,
    })
    bindVerticalCanvas(tabList, tabListLayout, 0, mobileTouchScroll)

    local content = create("Frame", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(sidebarWidth, 0),
        Size = UDim2.new(1, -sidebarWidth, 1, 0),
        Parent = body,
        ZIndex = 3,
    })
    corner(content, 10)

    -- Keep only the outer bottom-right corner rounded. Top and left are
    -- internal joins with the topbar/sidebar.
    create("Frame", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        Parent = content,
        ZIndex = 3,
    })

    create("Frame", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        Parent = content,
        ZIndex = 3,
    })

    local activeTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(22, 16),
        Size = UDim2.new(1, -40, 0, 22),
        FontFace = fontFace("SemiBold"),
        Text = "Tab",
        TextColor3 = Theme.Text,
        TextSize = fontSize(15),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content,
        ZIndex = 4,
    })

    local activeDescription = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(22, 39),
        Size = UDim2.new(1, -40, 0, 17),
        FontFace = fontFace("Regular"),
        Text = "",
        TextColor3 = Theme.TextDim,
        TextSize = fontSize(11),
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        Parent = content,
        ZIndex = 4,
    })

    local contentPadding = mobileMode and 14 or 22
    local pageContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(contentPadding, 66),
        Size = UDim2.new(1, -(contentPadding * 2), 1, -66),
        ClipsDescendants = true,
        Parent = content,
        ZIndex = 3,
    })

    local notificationPositionName = tostring(options.NotificationPosition or "BottomRight")
        :lower()
        :gsub("[%s_%-]", "")
    local notificationOnLeft = notificationPositionName:find("left", 1, true) ~= nil
    local notificationOnBottom = notificationPositionName:find("bottom", 1, true) ~= nil

    local notificationList = create("Frame", {
        AnchorPoint = Vector2.new(
            notificationOnLeft and 0 or 1,
            notificationOnBottom and 1 or 0
        ),
        BackgroundTransparency = 1,
        Position = UDim2.new(
            notificationOnLeft and 0 or 1,
            notificationOnLeft and 18 or -18,
            notificationOnBottom and 1 or 0,
            notificationOnBottom and -18 or 18
        ),
        Size = UDim2.fromOffset(300, 600),
        Parent = screenGui,
        ZIndex = 100,
    })
    local notificationLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = notificationOnLeft
            and Enum.HorizontalAlignment.Left
            or Enum.HorizontalAlignment.Right,
        VerticalAlignment = notificationOnBottom
            and Enum.VerticalAlignment.Bottom
            or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notificationList,
    })

    local window = setmetatable({
        ScreenGui = screenGui,
        Root = root,
        Shadow = shadow,
        Main = main,
        Body = body,
        Topbar = topbar,
        HeaderHeight = headerHeight,
        ThemeName = initialThemeName,
        LanguageName = initialLanguageName,
        NavigationLabel = navigationLabel,
        TabList = tabList,
        PageContainer = pageContainer,
        ActiveTitle = activeTitle,
        ActiveDescription = activeDescription,
        NotificationList = notificationList,
        NotificationLayout = notificationLayout,
        NotificationPosition = options.NotificationPosition or "BottomRight",
        Tabs = {},
        SelectedTab = nil,
        Visible = true,
        Minimized = false,
        Size = options.Size,
        ToggleKey = options.ToggleKey,
        MobileButton = nil,
        MobileMode = mobileMode,
        MobileTouchScroll = mobileTouchScroll,
        MobileDraggable = mobileDraggable,
        MobileScrollBottomPadding = math.max(tonumber(options.MobileScrollBottomPadding) or 28, 0),
        UIScale = uiScale,
        Config = config,
        LoadedConfig = loadedConfig,
        PendingSelectedTab = loadedConfig and loadedConfig.Window and loadedConfig.Window.SelectedTab or nil,
        Controls = {},
        Flags = {},
        _LoadingConfig = false,
        _Initializing = true,
        _SaveToken = 0,
        _LocaleUpdaters = {},
        _MinimizeTween = nil,
        _Closing = false,
    }, WindowMethods)

    window:_BindLocaleText(navigationLabel, "Text", "Navigation", "NAVIGATION")

    minimizeButton.MouseButton1Click:Connect(function()
        window:Minimize()
    end)

    closeButton.MouseButton1Click:Connect(function()
        window:Close()
    end)

    dragify(topbar, main, function(position)
        shadow.Position = UDim2.new(
            position.X.Scale,
            position.X.Offset,
            position.Y.Scale,
            position.Y.Offset + 8
        )
    end, function()
        -- Desktop window positions may be persisted. Mobile positions are
        -- intentionally ignored to avoid saving an accidental touch drag.
        if not window.MobileMode then
            window:_QueueAutoSave()
        end
    end, {
        AllowMouse = true,
        AllowTouch = mobileDraggable,
        MouseThreshold = 0,
        TouchThreshold = 12,
    })

    window.InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window.ToggleKey then
            window:Toggle()
        end
    end)

    if config.SaveMinimized and loadedConfig and loadedConfig.Window and loadedConfig.Window.Minimized == true then
        window._LoadingConfig = true
        window:Minimize(true)
        window._LoadingConfig = false
    end

    if options.MobileButton and UserInputService.TouchEnabled then
        local mobileButton = createTextButton({
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Theme.AccentDark,
            Position = UDim2.new(1, -14, 1, -14),
            Size = UDim2.fromOffset(52, 52),
            Visible = false,
            Parent = screenGui,
            ZIndex = 120,
        })
        corner(mobileButton, 14)
        stroke(mobileButton, Theme.Accent, 0.1, 1)
        local mobileIcon = createIcon(mobileButton, options.Icon, 22, Color3.fromRGB(255, 255, 255), 121)
        mobileIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        mobileIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
        mobileButton.MouseButton1Click:Connect(function()
            window:SetVisible(true)
        end)
        dragify(mobileButton, mobileButton, nil, nil, {
            AllowMouse = true,
            AllowTouch = true,
            MouseThreshold = 2,
            TouchThreshold = 10,
        })
        window.MobileButton = mobileButton
    end

    task.defer(function()
        if window.ScreenGui and window.ScreenGui.Parent then
            window._Initializing = false
        end
    end)

    VoltzUI.ActiveWindow = window
    return window
end


-- ============================================================================
-- VoltzUI 2.0 Pro Suite
-- Search, mobile drawer, color picker/theme editor, dialogs, lists, status,
-- tooltips, notification queue, advanced configs, dependencies and plugins.
-- ============================================================================

local V2_LOCALE_EXTRA = {
    English = {
        SearchControls = "Search controls...", ConfirmAction = "Confirm action", ConfirmQuestion = "Are you sure you want to continue?", ConfirmButton = "Confirm", CancelButton = "Cancel",
        ThemeEditorTitle = "Theme editor", ThemeEditorDesc = "Choose a preset or create your own colors", ThemePresetTitle = "Theme preset", ThemePresetDesc = "Start from a built-in color preset",
        ThemeTransferTitle = "Theme import / export", ThemeTransferDesc = "Copy or paste a VoltzUI theme JSON string", ExportTheme = "Export theme", ImportTheme = "Import theme",
        AdvancedConfigTitle = "Advanced config tools", AdvancedConfigDesc = "Rename, duplicate, export and import config profiles", TargetConfigName = "Target config name", TargetConfigDesc = "Used by rename, duplicate and import",
        ConfigTransferTitle = "Config import / export", ConfigTransferDesc = "Copy or paste a VoltzUI config JSON string", DuplicateConfig = "Duplicate current config", RenameConfig = "Rename current config", ExportConfig = "Export current config", ImportConfig = "Import as target config",
        SearchList = "Search list...", NoItems = "No items", SortOff = "Sort: Off",
    },
    ["ไทย"] = {
        SearchControls = "ค้นหาเมนู...", ConfirmAction = "ยืนยันการทำรายการ", ConfirmQuestion = "คุณแน่ใจหรือไม่ว่าต้องการดำเนินการต่อ?", ConfirmButton = "ยืนยัน", CancelButton = "ยกเลิก",
        ThemeEditorTitle = "ปรับแต่งธีม", ThemeEditorDesc = "เลือกธีมสำเร็จรูปหรือสร้างสีของคุณเอง", ThemePresetTitle = "ธีมสำเร็จรูป", ThemePresetDesc = "เลือกชุดสีเริ่มต้น",
        ThemeTransferTitle = "นำเข้า / ส่งออกธีม", ThemeTransferDesc = "คัดลอกหรือวางข้อความ JSON ของธีม VoltzUI", ExportTheme = "ส่งออกธีม", ImportTheme = "นำเข้าธีม",
        AdvancedConfigTitle = "เครื่องมือคอนฟิกขั้นสูง", AdvancedConfigDesc = "เปลี่ยนชื่อ ทำสำเนา นำเข้า และส่งออกคอนฟิก", TargetConfigName = "ชื่อคอนฟิกปลายทาง", TargetConfigDesc = "ใช้สำหรับเปลี่ยนชื่อ ทำสำเนา และนำเข้า",
        ConfigTransferTitle = "นำเข้า / ส่งออกคอนฟิก", ConfigTransferDesc = "คัดลอกหรือวางข้อความ JSON ของคอนฟิก VoltzUI", DuplicateConfig = "ทำสำเนาคอนฟิกปัจจุบัน", RenameConfig = "เปลี่ยนชื่อคอนฟิกปัจจุบัน", ExportConfig = "ส่งออกคอนฟิกปัจจุบัน", ImportConfig = "นำเข้าเป็นคอนฟิกปลายทาง",
        SearchList = "ค้นหาในรายการ...", NoItems = "ไม่มีข้อมูล", SortOff = "เรียง: ปิด",
    },
    ["日本語"] = { SearchControls = "コントロールを検索...", ConfirmAction = "操作を確認", ConfirmQuestion = "続行してもよろしいですか？", ConfirmButton = "確認", CancelButton = "キャンセル", SearchList = "リストを検索...", NoItems = "項目がありません" },
    ["简体中文"] = { SearchControls = "搜索控件...", ConfirmAction = "确认操作", ConfirmQuestion = "确定要继续吗？", ConfirmButton = "确认", CancelButton = "取消", SearchList = "搜索列表...", NoItems = "没有项目" },
    ["한국어"] = { SearchControls = "컨트롤 검색...", ConfirmAction = "작업 확인", ConfirmQuestion = "계속하시겠습니까?", ConfirmButton = "확인", CancelButton = "취소", SearchList = "목록 검색...", NoItems = "항목 없음" },
    ["Español"] = { SearchControls = "Buscar controles...", ConfirmAction = "Confirmar acción", ConfirmQuestion = "¿Seguro que quieres continuar?", ConfirmButton = "Confirmar", CancelButton = "Cancelar", SearchList = "Buscar en la lista...", NoItems = "Sin elementos" },
    ["Português"] = { SearchControls = "Pesquisar controles...", ConfirmAction = "Confirmar ação", ConfirmQuestion = "Tem certeza de que deseja continuar?", ConfirmButton = "Confirmar", CancelButton = "Cancelar", SearchList = "Pesquisar lista...", NoItems = "Sem itens" },
    ["Tiếng Việt"] = { SearchControls = "Tìm điều khiển...", ConfirmAction = "Xác nhận thao tác", ConfirmQuestion = "Bạn có chắc muốn tiếp tục?", ConfirmButton = "Xác nhận", CancelButton = "Hủy", SearchList = "Tìm trong danh sách...", NoItems = "Không có mục" },
}
for languageName, dictionary in pairs(V2_LOCALE_EXTRA) do
    LanguageDefinitions[languageName] = LanguageDefinitions[languageName] or {}
    for key, value in pairs(dictionary) do
        LanguageDefinitions[languageName][key] = value
    end
end

local function v2NormalizeText(value)
    return tostring(value or ""):lower():gsub("%s+", " ")
end

local function v2FindNewestFrame(section, title)
    if not section or not section.Container then
        return nil
    end
    local children = section.Container:GetChildren()
    for index = #children, 1, -1 do
        local child = children[index]
        if child:IsA("GuiObject") and (title == nil or child.Name == tostring(title)) then
            return child
        end
    end
    return nil
end

local function v2ColorToHex(color)
    if typeof(color) ~= "Color3" then
        return "#FFFFFF"
    end
    return string.format(
        "#%02X%02X%02X",
        math.clamp(math.floor(color.R * 255 + 0.5), 0, 255),
        math.clamp(math.floor(color.G * 255 + 0.5), 0, 255),
        math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    )
end

local function v2HexToColor(value, fallback)
    if typeof(value) == "Color3" then
        return value
    end
    if type(value) == "table" then
        local r = tonumber(value.R or value.r or value[1])
        local g = tonumber(value.G or value.g or value[2])
        local b = tonumber(value.B or value.b or value[3])
        if r and g and b then
            if r > 1 or g > 1 or b > 1 then
                return Color3.fromRGB(
                    math.clamp(math.floor(r + 0.5), 0, 255),
                    math.clamp(math.floor(g + 0.5), 0, 255),
                    math.clamp(math.floor(b + 0.5), 0, 255)
                )
            end
            return Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
        end
    end

    local text = tostring(value or ""):gsub("#", ""):gsub("0x", "")
    if #text == 3 then
        text = text:sub(1, 1) .. text:sub(1, 1)
            .. text:sub(2, 2) .. text:sub(2, 2)
            .. text:sub(3, 3) .. text:sub(3, 3)
    end
    if #text ~= 6 or not text:match("^[%da-fA-F]+$") then
        return fallback or Color3.new(1, 1, 1)
    end
    return Color3.fromRGB(
        tonumber(text:sub(1, 2), 16),
        tonumber(text:sub(3, 4), 16),
        tonumber(text:sub(5, 6), 16)
    )
end

local function v2SerializeThemePalette(palette)
    local result = {}
    for _, key in ipairs(THEME_COLOR_KEYS) do
        if typeof(palette[key]) == "Color3" then
            result[key] = v2ColorToHex(palette[key])
        end
    end
    return result
end

local function v2DeserializeThemePalette(data)
    local result = {}
    if type(data) ~= "table" then
        return result
    end
    for _, key in ipairs(THEME_COLOR_KEYS) do
        if data[key] ~= nil then
            result[key] = v2HexToColor(data[key], Theme[key])
        end
    end
    return result
end

function WindowMethods:_TrackConnection(connection)
    if connection then
        self._Connections = self._Connections or {}
        table.insert(self._Connections, connection)
    end
    return connection
end

function WindowMethods:_AddCleanup(callback)
    if type(callback) == "function" then
        self._CleanupCallbacks = self._CleanupCallbacks or {}
        table.insert(self._CleanupCallbacks, callback)
    end
    return callback
end


local function isPointInsideGui(guiObject, position)
    if not guiObject or not guiObject.Parent or not guiObject.Visible then
        return false
    end

    local absolutePosition = guiObject.AbsolutePosition
    local absoluteSize = guiObject.AbsoluteSize

    return position.X >= absolutePosition.X
        and position.X <= absolutePosition.X + absoluteSize.X
        and position.Y >= absolutePosition.Y
        and position.Y <= absolutePosition.Y + absoluteSize.Y
end

local function stopCurrentCharacterMovement()
    local character = LocalPlayer and LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid:Move(Vector3.zero, true)
        end)
    end
end

function WindowMethods:_IsTouchInsideVoltzUI(position)
    if not self.Visible
        or not self.Root
        or not self.Root.Visible
        or not self.ScreenGui
        or not self.ScreenGui.Parent then
        return false
    end

    -- The main window rectangle covers scrolling frames, dropdown headers,
    -- buttons and every standard component.
    if self.Main and isPointInsideGui(self.Main, position) then
        return true
    end

    -- Also catch Pro Suite overlays, confirmation dialogs, notifications and
    -- the mobile reopen button that may live outside the main window rectangle.
    local success, guiObjects = pcall(function()
        return GuiService:GetGuiObjectsAtPosition(position.X, position.Y)
    end)

    if success and type(guiObjects) == "table" then
        for _, guiObject in ipairs(guiObjects) do
            if guiObject == self.ScreenGui or guiObject:IsDescendantOf(self.ScreenGui) then
                return true
            end
        end
    end

    return self.MobileButton and isPointInsideGui(self.MobileButton, position) or false
end

function WindowMethods:_SetGameInputBlocked(blocked)
    if not self.BlockGameInputOnTouch or not UserInputService.TouchEnabled then
        return
    end

    blocked = blocked == true
    if self._GameInputBlocked == blocked then
        return
    end

    self._GameInputBlocked = blocked

    -- Clear any movement vector that may already have reached PlayerModule
    -- before the high-priority ContextAction callback processed the touch.
    if blocked then
        stopCurrentCharacterMovement()
    end
end

function WindowMethods:_ClearActiveUITouches()
    self._ActiveUITouches = {}
    self:_SetGameInputBlocked(false)
    stopCurrentCharacterMovement()
end

function WindowMethods:SetGameInputBlocked(blocked)
    self:_SetGameInputBlocked(blocked)
end

function WindowMethods:IsMobileInputGuardEnabled()
    return self.BlockGameInputOnTouch == true
end

function WindowMethods:_InitializeTouchInputGuard()
    -- Embedded behavior: always protect character movement while a touch is
    -- interacting with VoltzUI. This is intentionally not configurable from
    -- CreateWindow, so every script using this library gets the fix.
    self.BlockGameInputOnTouch = true
    self._ActiveUITouches = {}
    self._GameInputBlocked = false

    if not self.BlockGameInputOnTouch or not UserInputService.TouchEnabled then
        return
    end

    if self.Main then
        self.Main.Active = true
    end
    if self.Root then
        self.Root.Active = true
    end

    self._InputBlockActionName = "VoltzUI_BlockCharacterInput_"
        .. tostring(math.floor(os.clock() * 1000000))
        .. "_"
        .. tostring(math.random(1000, 9999))

    local blockedInputs = {
        Enum.PlayerActions.CharacterForward,
        Enum.PlayerActions.CharacterBackward,
        Enum.PlayerActions.CharacterLeft,
        Enum.PlayerActions.CharacterRight,
        Enum.PlayerActions.CharacterJump,
    }

    local bindSuccess, bindError = pcall(function()
        ContextActionService:BindActionAtPriority(
            self._InputBlockActionName,
            function()
                if self._GameInputBlocked then
                    return Enum.ContextActionResult.Sink
                end
                return Enum.ContextActionResult.Pass
            end,
            false,
            3000,
            table.unpack(blockedInputs)
        )
    end)

    if not bindSuccess then
        warn("[VoltzUI] Could not bind mobile input guard: " .. tostring(bindError))
        return
    end

    self._InputGuardBound = true

    self:_TrackConnection(UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if self:_IsTouchInsideVoltzUI(input.Position) then
            self._ActiveUITouches[input] = true
            self:_SetGameInputBlocked(true)
        end
    end))

    self:_TrackConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if self._ActiveUITouches[input] then
            self._ActiveUITouches[input] = nil
        end

        if next(self._ActiveUITouches) == nil then
            self:_SetGameInputBlocked(false)
            stopCurrentCharacterMovement()
        end
    end))

    -- Prevent a lost/cancelled touch from leaving movement blocked.
    self:_TrackConnection(UserInputService.WindowFocusReleased:Connect(function()
        self:_ClearActiveUITouches()
    end))

    self:_AddCleanup(function()
        self:_ClearActiveUITouches()
        if self._InputGuardBound and self._InputBlockActionName then
            pcall(function()
                ContextActionService:UnbindAction(self._InputBlockActionName)
            end)
        end
        self._InputGuardBound = false
    end)
end

function WindowMethods:_RegisterSearchEntry(tab, section, frame, options)
    if not tab or not frame then
        return nil
    end
    self._SearchEntries = self._SearchEntries or {}
    section._SearchEntries = section._SearchEntries or {}

    local entry = {
        Tab = tab,
        Section = section,
        Frame = frame,
        Text = v2NormalizeText(table.concat({
            tostring(options and options.Title or ""),
            tostring(options and options.Desc or ""),
            tostring(options and options.Keywords or ""),
            tostring(options and options.Flag or ""),
        }, " ")),
    }
    table.insert(self._SearchEntries, entry)
    table.insert(section._SearchEntries, entry)
    if self.SearchEnabled and self.SearchQuery and self.SearchQuery ~= "" then
        task.defer(function() self:ApplySearch(self.SearchQuery, tab) end)
    end
    return entry
end

function WindowMethods:ApplySearch(query, targetTab)
    local normalized = v2NormalizeText(query)
    self.SearchQuery = tostring(query or "")
    local tab = targetTab or self.SelectedTab
    if not tab then
        return
    end

    for _, section in ipairs(tab.Sections or {}) do
        local sectionText = v2NormalizeText((section.Title or "") .. " " .. (section.Description or ""))
        local sectionMatches = normalized == "" or sectionText:find(normalized, 1, true) ~= nil
        local visibleCount = 0

        for _, entry in ipairs(section._SearchEntries or {}) do
            if entry.Frame and entry.Frame.Parent then
                local visible = normalized == ""
                    or sectionMatches
                    or entry.Text:find(normalized, 1, true) ~= nil
                entry.Frame.Visible = visible
                if visible then
                    visibleCount = visibleCount + 1
                end
            end
        end

        if section.Frame and section.Frame.Parent then
            section.Frame.Visible = normalized == "" or sectionMatches or visibleCount > 0
        end
    end

    task.defer(function()
        if tab.RefreshScroll then
            tab:RefreshScroll()
        end
    end)
end

function WindowMethods:SetSearchQuery(query)
    if self.SearchBox then
        self.SearchBox.Text = tostring(query or "")
    else
        self:ApplySearch(query)
    end
end

function WindowMethods:SetSearchEnabled(value)
    local enabled = value == true
    self.SearchEnabled = enabled
    if self.SearchFrame then
        self.SearchFrame.Visible = enabled
    end
    if self.PageContainer then
        if enabled then
            self.PageContainer.Position = UDim2.fromOffset(22, 110)
            self.PageContainer.Size = UDim2.new(1, -44, 1, -110)
        else
            self.PageContainer.Position = UDim2.fromOffset(22, 66)
            self.PageContainer.Size = UDim2.new(1, -44, 1, -66)
        end
    end
    self:RefreshScrolling()
end

function WindowMethods:_AttachTooltip(guiObject, text)
    if not guiObject or text == nil then
        return nil
    end
    self._TooltipBindings = self._TooltipBindings or setmetatable({}, { __mode = "k" })
    local tooltipText = tostring(text)
    self._TooltipBindings[guiObject] = tooltipText

    local touchToken = 0
    self:_TrackConnection(guiObject.MouseEnter:Connect(function()
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
            return
        end
        self:ShowTooltip(tooltipText)
    end))
    self:_TrackConnection(guiObject.MouseLeave:Connect(function()
        self:HideTooltip()
    end))
    self:_TrackConnection(guiObject.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        touchToken = touchToken + 1
        local token = touchToken
        task.delay(0.55, function()
            if token == touchToken and guiObject.Parent then
                self:ShowTooltip(tooltipText, input.Position)
            end
        end)
    end))
    self:_TrackConnection(guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchToken = touchToken + 1
            self:HideTooltip()
        end
    end))
    return guiObject
end

function WindowMethods:ShowTooltip(text, position)
    if not self.TooltipFrame or not self.TooltipLabel then
        return
    end
    self.TooltipLabel.Text = tostring(text or "")
    self.TooltipFrame.Visible = true
    self.TooltipFrame.GroupTransparency = 1

    local mouse = position or UserInputService:GetMouseLocation()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    task.defer(function()
        if not self.TooltipFrame or not self.TooltipFrame.Parent then
            return
        end
        local size = self.TooltipFrame.AbsoluteSize
        local x = math.clamp(mouse.X + 14, 8, math.max(8, viewport.X - size.X - 8))
        local y = math.clamp(mouse.Y + 14, 8, math.max(8, viewport.Y - size.Y - 8))
        self.TooltipFrame.Position = UDim2.fromOffset(x, y)
        tween(self.TooltipFrame, 0.12, { GroupTransparency = 0 })
    end)
end

function WindowMethods:HideTooltip()
    if not self.TooltipFrame or not self.TooltipFrame.Visible then
        return
    end
    local frame = self.TooltipFrame
    tween(frame, 0.1, { GroupTransparency = 1 })
    task.delay(0.11, function()
        if frame and frame.Parent and frame.GroupTransparency >= 0.95 then
            frame.Visible = false
        end
    end)
end

local function v2DecorateController(window, controller, frame, options, section)
    if not controller or controller._VoltzV2Decorated then
        return controller
    end
    controller._VoltzV2Decorated = true
    controller.Frame = controller.Frame or frame
    controller.Options = controller.Options or options
    controller.Window = window
    controller.Section = section
    controller._Enabled = true

    local changedEvent = Instance.new("BindableEvent")
    controller._ChangedEvent = changedEvent
    controller.Changed = changedEvent.Event
    window:_AddCleanup(function()
        pcall(function()
            changedEvent:Destroy()
        end)
    end)

    if type(controller.Set) == "function" and type(controller.Get) == "function" then
        local originalSet = controller.Set
        function controller:Set(value, silent)
            originalSet(self, value, silent)
            if self._ChangedEvent then
                self._ChangedEvent:Fire(self:Get())
            end
        end
    end

    function controller:SetEnabled(value)
        self._Enabled = value ~= false
        if not self.Frame or not self.Frame.Parent then
            return self
        end
        if not self._DisableOverlay then
            self._DisableOverlay = create("TextButton", {
                Name = "VoltzDisableOverlay",
                BackgroundColor3 = Theme.Background,
                BackgroundTransparency = 0.72,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = self.Frame,
                ZIndex = 80,
            })
            corner(self._DisableOverlay, 12)
        end
        self._DisableOverlay.Visible = not self._Enabled
        return self
    end

    function controller:IsEnabled()
        return self._Enabled ~= false
    end

    function controller:DependsOn(sourceController, expected)
        local function refresh(value)
            local enabled
            if type(expected) == "function" then
                local ok, result = pcall(expected, value)
                enabled = ok and result == true
            elseif expected == nil then
                enabled = value == true
            else
                enabled = value == expected
            end
            self:SetEnabled(enabled)
        end

        if sourceController and type(sourceController.Get) == "function" then
            refresh(sourceController:Get())
        end
        if sourceController and sourceController.Changed then
            window:_TrackConnection(sourceController.Changed:Connect(refresh))
        end
        return self
    end

    function controller:SetTooltip(tooltipText)
        if self.Frame then
            window:_AttachTooltip(self.Frame, tooltipText)
        end
        return self
    end

    if options and options.Tooltip and frame then
        window:_AttachTooltip(frame, options.Tooltip)
    end
    if section and frame then
        window:_RegisterSearchEntry(section.Tab, section, frame, options or {})
    end
    return controller
end

local v2OriginalRegisterControl = WindowMethods._RegisterControl
function WindowMethods:_RegisterControl(section, options, controller, defaultValue, controlType)
    local result = v2OriginalRegisterControl(self, section, options, controller, defaultValue, controlType)
    local frame = result.Frame or v2FindNewestFrame(section, options and options.Title)
    return v2DecorateController(self, result, frame, options or {}, section)
end

local v2OriginalAddSection = TabMethods.AddSection
function TabMethods:AddSection(options)
    local rawOptions = type(options) == "table" and options or { Title = options }
    local section = v2OriginalAddSection(self, options)
    self.Sections = self.Sections or {}
    section.Description = rawOptions and rawOptions.Desc or nil
    section._SearchEntries = {}
    table.insert(self.Sections, section)
    return section
end

local function v2WrapNonRegisteredControl(methodName)
    local original = SectionMethods[methodName]
    SectionMethods[methodName] = function(self, options, ...)
        local rawOptions = type(options) == "table" and options or { Title = options }
        local controller = original(self, options, ...)
        local frame = controller and controller.Frame
            or v2FindNewestFrame(self, rawOptions.Title)
            or v2FindNewestFrame(self, nil)
        return v2DecorateController(self.Tab.Window, controller, frame, rawOptions, self)
    end
end

v2WrapNonRegisteredControl("AddButton")
v2WrapNonRegisteredControl("AddParagraph")

function SectionMethods:AddTextArea(options)
    options = merge({
        Title = "Text area",
        Desc = nil,
        Icon = "file-text",
        Placeholder = "Type or paste text...",
        Default = "",
        Height = 150,
        Save = false,
        Callback = function() end,
    }, options)

    local frame = create("Frame", {
        Name = options.Title,
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, math.max(tonumber(options.Height) or 150, 120)),
        Parent = self.Container,
    })
    corner(frame, 15)

    local iconObject = createIcon(frame, options.Icon, 18, Theme.TextMuted, 3)
    iconObject.Frame.Position = UDim2.fromOffset(16, 16)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(46, 10),
        Size = UDim2.new(1, -62, 0, 24),
        FontFace = fontFace("Medium"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(14),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 3,
    })

    local top = 40
    if options.Desc then
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(46, 34),
            Size = UDim2.new(1, -62, 0, 20),
            FontFace = fontFace("Regular"),
            Text = options.Desc,
            TextColor3 = Theme.TextMuted,
            TextSize = fontSize(11),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
            ZIndex = 3,
        })
        top = 60
    end

    local box = create("TextBox", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = fontFace("Regular"),
        PlaceholderColor3 = Theme.TextDim,
        PlaceholderText = options.Placeholder,
        Text = tostring(options.Default or ""),
        TextColor3 = Theme.Text,
        TextSize = fontSize(12),
        Position = UDim2.fromOffset(14, top),
        Size = UDim2.new(1, -28, 1, -(top + 14)),
        Parent = frame,
        ZIndex = 4,
    })
    corner(box, 11)
    padding(box, 12, 12, 10, 10)
    local boxStroke = stroke(box, Theme.Border, 0.22, 1)

    local controller = { Frame = frame, _Box = box }
    function controller:Set(value, silent)
        box.Text = tostring(value or "")
        if not silent then
            safeCallback(options.Callback, box.Text)
        end
    end
    function controller:Get()
        return box.Text
    end
    function controller:Focus()
        box:CaptureFocus()
    end
    function controller:Destroy()
        frame:Destroy()
    end

    self.Tab.Window:_TrackConnection(box.Focused:Connect(function()
        tween(boxStroke, 0.14, { Color = Theme.Accent, Transparency = 0 })
    end))
    self.Tab.Window:_TrackConnection(box.FocusLost:Connect(function()
        tween(boxStroke, 0.14, { Color = Theme.Border, Transparency = 0.22 })
        safeCallback(options.Callback, box.Text)
        if controller._Commit then
            controller:_Commit()
        end
    end))

    return self.Tab.Window:_RegisterControl(self, options, controller, options.Default, "textarea")
end

function SectionMethods:AddColorPicker(options)
    options = merge({
        Title = "Color",
        Desc = nil,
        Icon = "palette",
        Default = Theme.Accent,
        Callback = function() end,
    }, options)

    local collapsedHeight = options.Desc and 72 or 62
    local expandedHeight = collapsedHeight + 164
    local base = createElementBase(self, options, collapsedHeight)
    if base.Icon and base.Icon.Frame then
        base.Icon.Frame.Position = UDim2.fromOffset(16, options.Desc and 24 or 22)
    end

    local current = v2HexToColor(options.Default, Theme.Accent)
    local open = false
    local preview = createTextButton({
        BackgroundColor3 = current,
        Position = UDim2.new(1, -58, 0, options.Desc and 18 or 14),
        Size = UDim2.fromOffset(40, 32),
        Parent = base.Frame,
        ZIndex = 6,
    })
    corner(preview, 10)
    stroke(preview, Theme.Border, 0.08, 1)

    local panel = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, collapsedHeight + 6),
        Size = UDim2.new(1, -28, 0, 150),
        Visible = false,
        Parent = base.Frame,
        ZIndex = 5,
    })

    local hexBox = create("TextBox", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        FontFace = fontFace("Medium"),
        Text = v2ColorToHex(current),
        PlaceholderText = "#32B4FD",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = fontSize(12),
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.new(1, -112, 0, 0),
        Size = UDim2.fromOffset(112, 32),
        Parent = panel,
        ZIndex = 6,
    })
    corner(hexBox, 9)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -122, 0, 32),
        FontFace = fontFace("Regular"),
        Text = "HEX",
        TextColor3 = Theme.TextMuted,
        TextSize = fontSize(11),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = panel,
        ZIndex = 6,
    })

    local rows = {}
    local controller = { Frame = base.Frame }
    local updating = false

    local function channelValue(channel)
        if channel == "R" then return current.R end
        if channel == "G" then return current.G end
        return current.B
    end

    local function composeColor(channel, value)
        local r, g, b = current.R, current.G, current.B
        if channel == "R" then r = value elseif channel == "G" then g = value else b = value end
        return Color3.new(r, g, b)
    end

    local function updateVisuals()
        updating = true
        preview.BackgroundColor3 = current
        hexBox.Text = v2ColorToHex(current)
        for channel, row in pairs(rows) do
            local value = channelValue(channel)
            row.Fill.Size = UDim2.new(value, 0, 1, 0)
            row.Knob.Position = UDim2.new(value, 0, 0.5, 0)
            row.Value.Text = tostring(math.floor(value * 255 + 0.5))
        end
        updating = false
    end

    local function addChannel(channel, y, color)
        local row = create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, y),
            Size = UDim2.new(1, 0, 0, 31),
            Parent = panel,
            ZIndex = 6,
        })
        create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(22, 31),
            FontFace = fontFace("Medium"),
            Text = channel,
            TextColor3 = color,
            TextSize = fontSize(12),
            Parent = row,
            ZIndex = 7,
        })
        local bar = create("TextButton", {
            AutoButtonColor = false,
            Text = "",
            BackgroundColor3 = Theme.Surface3,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(30, 12),
            Size = UDim2.new(1, -86, 0, 7),
            Parent = row,
            ZIndex = 7,
        })
        corner(bar, 99)
        local fill = create("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = bar,
            ZIndex = 8,
        })
        corner(fill, 99)
        local knob = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            Parent = bar,
            ZIndex = 9,
        })
        corner(knob, 99)
        local valueLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(48, 31),
            FontFace = fontFace("Regular"),
            Text = "0",
            TextColor3 = Theme.TextMuted,
            TextSize = fontSize(11),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = row,
            ZIndex = 7,
        })
        rows[channel] = { Bar = bar, Fill = fill, Knob = knob, Value = valueLabel }

        local dragging = false
        local function updateFromX(x)
            local width = math.max(bar.AbsoluteSize.X, 1)
            local alpha = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
            controller:Set(composeColor(channel, alpha))
        end
        self.Tab.Window:_TrackConnection(bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromX(input.Position.X)
            end
        end))
        self.Tab.Window:_TrackConnection(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(input.Position.X)
            end
        end))
        self.Tab.Window:_TrackConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end

    addChannel("R", 39, Color3.fromRGB(248, 113, 113))
    addChannel("G", 76, Color3.fromRGB(74, 222, 128))
    addChannel("B", 113, Color3.fromRGB(96, 165, 250))

    local function setOpen(value)
        open = value == true
        panel.Visible = open
        tween(base.Frame, 0.2, {
            Size = UDim2.new(1, 0, 0, open and expandedHeight or collapsedHeight),
        }, Enum.EasingStyle.Quint)
        task.defer(function()
            if self.Tab and self.Tab.RefreshScroll then
                self.Tab:RefreshScroll()
            end
        end)
    end

    function controller:Set(value, silent)
        current = v2HexToColor(value, current)
        updateVisuals()
        if not silent then
            safeCallback(options.Callback, current, v2ColorToHex(current))
        end
    end
    function controller:Get()
        return current
    end
    function controller:Open()
        setOpen(true)
    end
    function controller:Close()
        setOpen(false)
    end
    function controller:Destroy()
        base.Frame:Destroy()
    end

    self.Tab.Window:_TrackConnection(preview.MouseButton1Click:Connect(function()
        setOpen(not open)
    end))
    self.Tab.Window:_TrackConnection(hexBox.FocusLost:Connect(function()
        if not updating then
            controller:Set(hexBox.Text)
        end
    end))

    updateVisuals()
    return self.Tab.Window:_RegisterControl(self, options, controller, current, "colorpicker")
end

local V2_STATUS_PRESETS = {
    Online = { Text = "Online", Color = Color3.fromRGB(74, 222, 128) },
    Active = { Text = "Active", Color = Color3.fromRGB(74, 222, 128) },
    Running = { Text = "Running", Color = Color3.fromRGB(50, 180, 253) },
    Loading = { Text = "Loading", Color = Color3.fromRGB(250, 204, 21) },
    Waiting = { Text = "Waiting", Color = Color3.fromRGB(250, 204, 21) },
    Warning = { Text = "Warning", Color = Color3.fromRGB(251, 146, 60) },
    Offline = { Text = "Offline", Color = Color3.fromRGB(148, 163, 184) },
    Disabled = { Text = "Disabled", Color = Color3.fromRGB(148, 163, 184) },
    Error = { Text = "Error", Color = Color3.fromRGB(248, 113, 113) },
}

function SectionMethods:AddStatus(options)
    options = merge({
        Title = "Status",
        Desc = nil,
        Icon = "activity",
        Default = "Offline",
    }, options)

    local base = createElementBase(self, options)
    local badge = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, -15),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.fromOffset(0, 30),
        Parent = base.Frame,
        ZIndex = 5,
    })
    corner(badge, 99)
    padding(badge, 11, 11, 0, 0)
    local layout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 7),
        Parent = badge,
    })
    local dot = create("Frame", {
        BackgroundColor3 = Theme.TextDim,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(8, 8),
        Parent = badge,
        ZIndex = 6,
    })
    corner(dot, 99)
    local label = create("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 30),
        FontFace = fontFace("Medium"),
        Text = "Offline",
        TextColor3 = Theme.Text,
        TextSize = fontSize(11),
        Parent = badge,
        ZIndex = 6,
    })

    local current = options.Default
    local controller = { Frame = base.Frame }
    function controller:SetStatus(status, customText, customColor)
        current = status
        local preset = type(status) == "table" and status or V2_STATUS_PRESETS[tostring(status)]
        local displayText = customText
            or (type(preset) == "table" and preset.Text)
            or tostring(status or "Unknown")
        local displayColor = customColor
            or (type(preset) == "table" and preset.Color)
            or Theme.TextDim
        label.Text = displayText
        dot.BackgroundColor3 = displayColor
        return self
    end
    function controller:Set(value)
        self:SetStatus(value)
    end
    function controller:Get()
        return current
    end
    function controller:Destroy()
        base.Frame:Destroy()
    end
    controller:SetStatus(options.Default)
    return v2DecorateController(self.Tab.Window, controller, base.Frame, options, self)
end

function SectionMethods:AddList(options)
    local listWindow = self.Tab.Window
    options = merge({
        Title = "List",
        Desc = nil,
        Icon = "list",
        Items = {},
        Height = 330,
        Searchable = true,
        Sortable = true,
        EmptyText = listWindow:T("NoItems", "No items"),
        ItemHeight = 64,
        ActionText = "Open",
        OnAction = function() end,
    }, options)

    local frame = create("Frame", {
        Name = options.Title,
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, math.max(tonumber(options.Height) or 330, 210)),
        Parent = self.Container,
    })
    corner(frame, 15)

    local iconObject = createIcon(frame, options.Icon, 18, Theme.Accent, 4)
    iconObject.Frame.Position = UDim2.fromOffset(16, 16)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(46, 9),
        Size = UDim2.new(1, -160, 0, 25),
        FontFace = fontFace("Medium"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(14),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 4,
    })
    if options.Desc then
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(46, 34),
            Size = UDim2.new(1, -160, 0, 18),
            FontFace = fontFace("Regular"),
            Text = options.Desc,
            TextColor3 = Theme.TextMuted,
            TextSize = fontSize(11),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
            ZIndex = 4,
        })
    end

    local headerHeight = options.Desc and 62 or 50
    local searchBox
    if options.Searchable then
        searchBox = create("TextBox", {
            BackgroundColor3 = Theme.Surface3,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            FontFace = fontFace("Regular"),
            PlaceholderText = listWindow:T("SearchList", "Search list..."),
            PlaceholderColor3 = Theme.TextDim,
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = fontSize(11),
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(14, headerHeight),
            Size = UDim2.new(1, options.Sortable and -128 or -28, 0, 34),
            Parent = frame,
            ZIndex = 5,
        })
        corner(searchBox, 10)
        padding(searchBox, 11, 11, 0, 0)
        headerHeight = headerHeight + 44
    end

    local sortButton
    if options.Sortable then
        sortButton = createTextButton({
            BackgroundColor3 = Theme.Surface3,
            Position = UDim2.new(1, -104, 0, options.Desc and 62 or 50),
            Size = UDim2.fromOffset(90, 34),
            Text = listWindow:T("SortOff", "Sort: Off"),
            TextSize = fontSize(10),
            Parent = frame,
            ZIndex = 5,
        })
        corner(sortButton, 10)
    end

    local list = create("ScrollingFrame", {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        Position = UDim2.fromOffset(14, headerHeight),
        Size = UDim2.new(1, -28, 1, -(headerHeight + 14)),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Border,
        Parent = frame,
        ZIndex = 4,
    })
    local listLayout = create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })
    local refreshCanvas = bindVerticalCanvas(list, listLayout, 4, self.Tab.Window.MobileTouchScroll)

    local controller = {
        Frame = frame,
        Items = deepClone(options.Items or {}),
        Search = "",
        SortMode = "Off",
        _Rows = {},
    }

    local function itemSearchText(item)
        return v2NormalizeText(table.concat({
            tostring(item.Title or item.Name or ""),
            tostring(item.Description or item.Desc or ""),
            tostring(item.Status or ""),
            tostring(item.Keywords or ""),
        }, " "))
    end

    local function clearRows()
        for _, row in ipairs(controller._Rows) do
            if row and row.Parent then
                row:Destroy()
            end
        end
        controller._Rows = {}
    end

    local function render()
        clearRows()
        local filtered = {}
        local search = v2NormalizeText(controller.Search)
        for index, rawItem in ipairs(controller.Items) do
            local item = type(rawItem) == "table" and rawItem or { Title = tostring(rawItem) }
            item._OriginalIndex = index
            if search == "" or itemSearchText(item):find(search, 1, true) then
                table.insert(filtered, item)
            end
        end

        if controller.SortMode ~= "Off" then
            table.sort(filtered, function(a, b)
                local left = tostring(a.Title or a.Name or ""):lower()
                local right = tostring(b.Title or b.Name or ""):lower()
                if controller.SortMode == "A-Z" then
                    return left < right
                end
                return left > right
            end)
        end

        if #filtered == 0 then
            local empty = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 48),
                FontFace = fontFace("Regular"),
                Text = options.EmptyText,
                TextColor3 = Theme.TextDim,
                TextSize = fontSize(12),
                Parent = list,
                ZIndex = 5,
            })
            table.insert(controller._Rows, empty)
        end

        for renderIndex, item in ipairs(filtered) do
            local row = create("Frame", {
                BackgroundColor3 = Theme.Surface3,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -4, 0, math.max(tonumber(options.ItemHeight) or 64, 54)),
                LayoutOrder = renderIndex,
                Parent = list,
                ZIndex = 5,
            })
            corner(row, 12)
            table.insert(controller._Rows, row)

            local showAction = item.ActionText ~= false and options.ActionText ~= false
            local left = 14
            if item.Icon then
                local itemIcon = createIcon(row, item.Icon, 17, item.IconColor or Theme.TextMuted, 6)
                itemIcon.Frame.Position = UDim2.new(0, 14, 0.5, -8)
                left = 43
            end

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(left, 8),
                Size = UDim2.new(1, showAction and -(left + 112) or -(left + 14), 0, 22),
                FontFace = fontFace("Medium"),
                Text = tostring(item.Title or item.Name or "Item"),
                TextColor3 = Theme.Text,
                TextSize = fontSize(12),
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
                ZIndex = 6,
            })
            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(left, 31),
                Size = UDim2.new(1, showAction and -(left + 112) or -(left + 14), 0, 19),
                FontFace = fontFace("Regular"),
                Text = tostring(item.Description or item.Desc or ""),
                TextColor3 = Theme.TextMuted,
                TextSize = fontSize(10),
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
                ZIndex = 6,
            })

            if item.Status then
                local statusPreset = V2_STATUS_PRESETS[tostring(item.Status)] or {}
                local statusDot = create("Frame", {
                    BackgroundColor3 = item.StatusColor or statusPreset.Color or Theme.TextDim,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -112, 0, 13),
                    Size = UDim2.fromOffset(7, 7),
                    Parent = row,
                    ZIndex = 7,
                })
                corner(statusDot, 99)
            end

            if showAction then
                local action = createTextButton({
                    BackgroundColor3 = Theme.Surface2,
                    Position = UDim2.new(1, -96, 0.5, -16),
                    Size = UDim2.fromOffset(82, 32),
                    Text = tostring(item.ActionText or options.ActionText),
                    TextSize = fontSize(11),
                    Parent = row,
                    ZIndex = 7,
                })
                corner(action, 10)
                self.Tab.Window:_TrackConnection(action.MouseButton1Click:Connect(function()
                    safeCallback(item.Callback or options.OnAction, item, item._OriginalIndex, controller)
                end))
            end
        end
        task.defer(refreshCanvas)
    end

    function controller:SetItems(items)
        self.Items = deepClone(type(items) == "table" and items or {})
        render()
        return self
    end
    function controller:AddItem(item)
        table.insert(self.Items, deepClone(item))
        render()
        return self
    end
    function controller:RemoveItem(idOrIndex)
        for index = #self.Items, 1, -1 do
            local item = self.Items[index]
            if index == idOrIndex or (type(item) == "table" and (item.Id == idOrIndex or item.Key == idOrIndex)) then
                table.remove(self.Items, index)
                break
            end
        end
        render()
        return self
    end
    function controller:Clear()
        self.Items = {}
        render()
        return self
    end
    function controller:GetItems()
        return deepClone(self.Items)
    end
    function controller:SetSearch(value)
        self.Search = tostring(value or "")
        if searchBox and searchBox.Text ~= self.Search then
            searchBox.Text = self.Search
        end
        render()
        return self
    end
    function controller:SetSort(mode)
        local valid = { ["Off"] = true, ["A-Z"] = true, ["Z-A"] = true }
        self.SortMode = valid[mode] and mode or "Off"
        if sortButton then
            sortButton.Text = "Sort: " .. self.SortMode
        end
        render()
        return self
    end
    function controller:Refresh()
        render()
        return self
    end
    function controller:Destroy()
        frame:Destroy()
    end

    if searchBox then
        self.Tab.Window:_TrackConnection(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            controller.Search = searchBox.Text
            render()
        end))
    end
    if sortButton then
        self.Tab.Window:_TrackConnection(sortButton.MouseButton1Click:Connect(function()
            if controller.SortMode == "Off" then
                controller:SetSort("A-Z")
            elseif controller.SortMode == "A-Z" then
                controller:SetSort("Z-A")
            else
                controller:SetSort("Off")
            end
        end))
    end

    render()
    return v2DecorateController(self.Tab.Window, controller, frame, options, self)
end

function WindowMethods:Confirm(options)
    options = merge({
        Title = self:T("ConfirmAction", "Confirm action"),
        Content = self:T("ConfirmQuestion", "Are you sure you want to continue?"),
        ConfirmText = self:T("ConfirmButton", "Confirm"),
        CancelText = self:T("CancelButton", "Cancel"),
        Danger = false,
        Callback = function() end,
    }, options)

    if self._ActiveDialog and self._ActiveDialog.Close then
        self._ActiveDialog:Close(false)
    end

    local overlay = create("TextButton", {
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = self.ScreenGui,
        ZIndex = 400,
    })

    local card = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Active = true,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(390, 220),
        Parent = overlay,
        ZIndex = 401,
    })
    corner(card, 16)
    stroke(card, Theme.Border, 0.12, 1)

    local dialogIcon = createIcon(card, options.Danger and "triangle-alert" or "circle-help", 24,
        options.Danger and Theme.Danger or Theme.Accent, 402)
    dialogIcon.Frame.Position = UDim2.fromOffset(20, 20)
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(58, 14),
        Size = UDim2.new(1, -78, 0, 34),
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(16),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
        ZIndex = 402,
    })
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 62),
        Size = UDim2.new(1, -40, 0, 84),
        FontFace = fontFace("Regular"),
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextSize = fontSize(12),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
        ZIndex = 402,
    })

    local cancel = createTextButton({
        BackgroundColor3 = Theme.Surface3,
        Position = UDim2.new(1, -206, 1, -54),
        Size = UDim2.fromOffset(88, 36),
        Text = options.CancelText,
        Parent = card,
        ZIndex = 402,
    })
    corner(cancel, 10)
    local confirm = createTextButton({
        BackgroundColor3 = options.Danger and Theme.Danger or Theme.AccentDark,
        Position = UDim2.new(1, -108, 1, -54),
        Size = UDim2.fromOffset(88, 36),
        Text = options.ConfirmText,
        Parent = card,
        ZIndex = 402,
    })
    corner(confirm, 10)

    local windowReference = self
    local controller = { Overlay = overlay, Closed = false }
    function controller:Close(result)
        if self.Closed then
            return
        end
        self.Closed = true
        safeCallback(options.Callback, result == true)
        if overlay and overlay.Parent then
            overlay:Destroy()
        end
        if windowReference and windowReference._ActiveDialog == self then
            windowReference._ActiveDialog = nil
        end
    end

    self._ActiveDialog = controller
    self:_TrackConnection(cancel.MouseButton1Click:Connect(function()
        controller:Close(false)
    end))
    self:_TrackConnection(confirm.MouseButton1Click:Connect(function()
        controller:Close(true)
    end))
    self:_TrackConnection(overlay.MouseButton1Click:Connect(function()
        controller:Close(false)
    end))
    return controller
end

function WindowMethods:ConfirmAsync(options)
    local event = Instance.new("BindableEvent")
    local result
    local originalCallback = options and options.Callback
    local dialogOptions = merge({}, options)
    dialogOptions.Callback = function(value)
        result = value
        safeCallback(originalCallback, value)
        event:Fire()
    end
    self:Confirm(dialogOptions)
    event.Event:Wait()
    event:Destroy()
    return result
end

local v2OriginalNotify = WindowMethods.Notify
function WindowMethods:Notify(options)
    if type(options) == "string" then
        options = { Title = options }
    end
    options = merge({
        Title = "Notification",
        Content = "",
        Duration = 4,
        Icon = "bell",
        Type = "Info",
        Id = nil,
        ActionText = nil,
        ActionCallback = nil,
        Closable = true,
    }, options)

    self._Notifications = self._Notifications or {}
    self._NotificationById = self._NotificationById or {}
    self.MaxNotifications = tonumber(self.MaxNotifications) or 4

    if options.Id and self._NotificationById[options.Id] then
        local existing = self._NotificationById[options.Id]
        existing:Update(options)
        return existing
    end

    local accent = Theme.Accent
    if options.Type == "Success" then accent = Theme.Success
    elseif options.Type == "Warning" then accent = Theme.Warning
    elseif options.Type == "Error" or options.Type == "Danger" then accent = Theme.Danger end

    local card = create("CanvasGroup", {
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(320, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
        Parent = self.NotificationList,
        ZIndex = 100,
    })
    corner(card, 13)
    stroke(card, Theme.Border, 0.16, 1)
    padding(card, 14, 14, 12, 10)
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = card,
    })

    local header = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 23),
        LayoutOrder = 1,
        Parent = card,
        ZIndex = 101,
    })
    local icon = createIcon(header, options.Icon, 18, accent, 102)
    icon.Frame.Position = UDim2.fromOffset(0, 2)
    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, options.Closable and -52 or -28, 1, 0),
        FontFace = fontFace("SemiBold"),
        Text = options.Title,
        TextColor3 = Theme.Text,
        TextSize = fontSize(13),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
        ZIndex = 102,
    })
    local closeButton
    if options.Closable then
        closeButton = createTextButton({
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -24, 0, 0),
            Size = UDim2.fromOffset(24, 23),
            Text = "×",
            TextColor3 = Theme.TextMuted,
            TextSize = fontSize(16),
            Parent = header,
            ZIndex = 103,
        })
    end

    local contentLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        FontFace = fontFace("Regular"),
        Text = options.Content,
        TextColor3 = Theme.TextMuted,
        TextSize = fontSize(11),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
        ZIndex = 102,
    })

    local actionButton
    if options.ActionText then
        actionButton = createTextButton({
            BackgroundColor3 = Theme.Surface3,
            Size = UDim2.new(1, 0, 0, 31),
            LayoutOrder = 3,
            Text = options.ActionText,
            TextSize = fontSize(11),
            Parent = card,
            ZIndex = 102,
        })
        corner(actionButton, 9)
    end

    local progressBackground = create("Frame", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 3),
        LayoutOrder = 4,
        Parent = card,
        ZIndex = 102,
    })
    corner(progressBackground, 99)
    local progress = create("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = progressBackground,
        ZIndex = 103,
    })
    corner(progress, 99)

    local controller = {
        Card = card,
        Id = options.Id,
        Closed = false,
        Token = 0,
    }

    local function removeFromQueue()
        for index = #self._Notifications, 1, -1 do
            if self._Notifications[index] == controller then
                table.remove(self._Notifications, index)
                break
            end
        end
        if controller.Id and self._NotificationById[controller.Id] == controller then
            self._NotificationById[controller.Id] = nil
        end
    end

    function controller:Close()
        if self.Closed then return end
        self.Closed = true
        removeFromQueue()
        tween(card, 0.16, { GroupTransparency = 1 })
        task.delay(0.17, function()
            if card and card.Parent then card:Destroy() end
        end)
    end

    function controller:Update(newOptions)
        if self.Closed then return self end
        newOptions = merge(options, newOptions)
        options = newOptions
        titleLabel.Text = tostring(options.Title or "Notification")
        contentLabel.Text = tostring(options.Content or "")
        self.Token = self.Token + 1
        local token = self.Token
        progress.Size = UDim2.fromScale(1, 1)
        local duration = math.max(tonumber(options.Duration) or 4, 0.2)
        tween(progress, duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)
        task.delay(duration, function()
            if not self.Closed and token == self.Token then
                self:Close()
            end
        end)
        return self
    end

    if closeButton then
        self:_TrackConnection(closeButton.MouseButton1Click:Connect(function()
            controller:Close()
        end))
    end
    if actionButton then
        self:_TrackConnection(actionButton.MouseButton1Click:Connect(function()
            safeCallback(options.ActionCallback, controller)
        end))
    end

    table.insert(self._Notifications, controller)
    if options.Id then self._NotificationById[options.Id] = controller end
    while #self._Notifications > self.MaxNotifications do
        local oldest = self._Notifications[1]
        if oldest then oldest:Close() else break end
    end

    task.defer(function()
        if card and card.Parent then
            tween(card, 0.18, { GroupTransparency = 0 }, Enum.EasingStyle.Quint)
        end
    end)
    controller:Update(options)
    return controller
end

function WindowMethods:ExportTheme()
    local payload = {
        Version = 1,
        Name = self.ThemeName or ActiveThemeName or "Custom",
        Colors = v2SerializeThemePalette(Theme),
    }
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    return ok, encoded
end

function WindowMethods:ImportTheme(source)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(tostring(source or ""))
    end)
    if not ok or type(data) ~= "table" then
        return false, "Invalid theme JSON"
    end
    local palette = v2DeserializeThemePalette(data.Colors or data)
    palette.Name = tostring(data.Name or "Custom")
    return self:SetTheme(palette)
end

function WindowMethods:AddThemeEditor(tab, options)
    options = merge({
        Title = self:T("ThemeEditorTitle", "Theme editor"),
        Desc = self:T("ThemeEditorDesc", "Choose a preset or create your own colors"),
        IncludeTransfer = true,
    }, options)

    local section = tab:AddSection({ Title = options.Title, Desc = options.Desc })
    local pickers = {}
    local preset = self:_AddThemeControls(section, {
        Title = options.PresetTitle or self:T("ThemePresetTitle", "Theme preset"),
        Desc = options.PresetDesc or self:T("ThemePresetDesc", "Start from a built-in color preset"),
        Flag = options.PresetFlag or "__VoltzTheme",
        Callback = function()
            task.defer(function()
                for key, picker in pairs(pickers) do
                    if picker and picker.Set then picker:Set(Theme[key], true) end
                end
            end)
        end,
    })

    local editableKeys = options.Keys or { "Accent", "Background", "Surface2", "Surface3", "Border", "Text" }
    for _, key in ipairs(editableKeys) do
        pickers[key] = section:AddColorPicker({
            Title = key,
            Desc = "Customize " .. key,
            Icon = key == "Text" and "type" or "palette",
            Default = Theme[key],
            Flag = "__VoltzThemeColor_" .. key,
            Callback = function(color)
                local palette = cloneTable(Theme)
                palette.Name = "Custom"
                palette[key] = color
                self:SetTheme(palette)
            end,
        })
    end

    if options.IncludeTransfer ~= false then
        local transfer = section:AddTextArea({
            Title = self:T("ThemeTransferTitle", "Theme import / export"),
            Desc = self:T("ThemeTransferDesc", "Copy or paste a VoltzUI theme JSON string"),
            Icon = "braces",
            Height = 170,
            Save = false,
        })
        section:AddButton({
            Title = self:T("ExportTheme", "Export theme"),
            Desc = "Put the current theme JSON into the text area",
            Icon = "upload",
            ButtonText = "Export",
            Callback = function()
                local ok, result = self:ExportTheme()
                if ok then transfer:Set(result, true) end
            end,
        })
        section:AddButton({
            Title = self:T("ImportTheme", "Import theme"),
            Desc = "Apply the JSON currently inside the text area",
            Icon = "download",
            ButtonText = "Import",
            Callback = function()
                local ok, message = self:ImportTheme(transfer:Get())
                self:Notify({
                    Title = ok and "Theme imported" or "Theme import failed",
                    Content = tostring(message),
                    Type = ok and "Success" or "Error",
                })
            end,
        })
    end

    return section, pickers, preset
end

function WindowMethods:ExportConfig(configName)
    if configName then self:SetConfigName(configName) end
    if not fileSystemAvailable() then
        return false, "Executor file functions are unavailable"
    end
    local okExists, exists = pcall(isfile, self.Config.Path)
    if not okExists or not exists then
        local saved, saveMessage = self:SaveConfig(self.Config.FileName)
        if not saved then return false, saveMessage end
    end
    local ok, content = pcall(readfile, self.Config.Path)
    if not ok then return false, tostring(content) end
    return true, content
end

function WindowMethods:ImportConfig(source, configName)
    if not self.Config.Enabled then return false, "Config is disabled" end
    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(tostring(source or ""))
    end)
    if not okDecode or type(data) ~= "table" or type(data.Values) ~= "table" then
        return false, "Invalid VoltzUI config JSON"
    end
    self:SetConfigName(configName or self.Config.FileName)
    ensureFolder(self.Config.Folder)
    local okEncode, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not okEncode then return false, tostring(encoded) end
    local okWrite, writeError = pcall(writefile, self.Config.Path, encoded)
    if not okWrite then return false, tostring(writeError) end
    return true, self.Config.Path
end

function WindowMethods:DuplicateConfig(sourceName, targetName)
    local sourcePath = buildConfigPath(self.Config.Folder, sourceName)
    local targetPath, safeTarget = buildConfigPath(self.Config.Folder, targetName)
    local okTarget, targetExists = pcall(isfile, targetPath)
    if okTarget and targetExists then return false, "Target config already exists: " .. safeTarget end
    local okRead, content = pcall(readfile, sourcePath)
    if not okRead then return false, tostring(content) end
    ensureFolder(self.Config.Folder)
    local okWrite, writeError = pcall(writefile, targetPath, content)
    if not okWrite then return false, tostring(writeError) end
    return true, safeTarget
end

function WindowMethods:RenameConfig(sourceName, targetName)
    local sourcePath, safeSource = buildConfigPath(self.Config.Folder, sourceName)
    local targetPath, safeTarget = buildConfigPath(self.Config.Folder, targetName)
    if safeTarget == safeSource then return true, safeTarget end
    local okTarget, targetExists = pcall(isfile, targetPath)
    if okTarget and targetExists and safeTarget ~= safeSource then return false, "Target config already exists: " .. safeTarget end
    local okRead, content = pcall(readfile, sourcePath)
    if not okRead then return false, tostring(content) end
    local okWrite, writeError = pcall(writefile, targetPath, content)
    if not okWrite then return false, tostring(writeError) end
    if type(delfile) == "function" then pcall(delfile, sourcePath) end
    if self:GetAutoloadConfig() == safeSource then
        self:SetAutoloadConfig(safeTarget)
    end
    if self.Config.FileName == safeSource then self:SetConfigName(safeTarget) end
    return true, safeTarget
end

function WindowMethods:GetConfigMetadata(configName)
    local path, safeName = buildConfigPath(self.Config.Folder, configName or self.Config.FileName)
    local metadata = {
        Name = safeName,
        Path = path,
        Exists = false,
        Size = 0,
        IsActive = self.Config.FileName == safeName,
        IsAutoload = self:GetAutoloadConfig() == safeName,
    }
    local okExists, exists = pcall(isfile, path)
    metadata.Exists = okExists and exists == true
    if metadata.Exists then
        local okRead, content = pcall(readfile, path)
        if okRead and type(content) == "string" then metadata.Size = #content end
        if type(getfileinfo) == "function" then
            local okInfo, info = pcall(getfileinfo, path)
            if okInfo and type(info) == "table" then metadata.FileInfo = info end
        end
    end
    return metadata
end

function WindowMethods:AddAdvancedConfigSection(tab, options)
    options = merge({
        Title = self:T("AdvancedConfigTitle", "Advanced config tools"),
        Desc = self:T("AdvancedConfigDesc", "Rename, duplicate, export and import config profiles"),
    }, options)
    self._AdvancedConfigTabs = self._AdvancedConfigTabs or setmetatable({}, { __mode = "k" })
    if self._AdvancedConfigTabs[tab] then
        return self._AdvancedConfigTabs[tab]
    end

    local section = tab:AddSection({ Title = options.Title, Desc = options.Desc })
    self._AdvancedConfigTabs[tab] = section

    local targetName = section:AddInput({
        Title = self:T("TargetConfigName", "Target config name"),
        Desc = self:T("TargetConfigDesc", "Used by rename, duplicate and import"),
        Icon = "file-pen-line",
        Default = self.Config.FileName .. "_copy",
        Save = false,
    })
    local transfer = section:AddTextArea({
        Title = self:T("ConfigTransferTitle", "Config import / export"),
        Desc = self:T("ConfigTransferDesc", "Copy or paste a VoltzUI config JSON string"),
        Icon = "braces",
        Height = 190,
        Save = false,
    })

    section:AddButton({
        Title = self:T("DuplicateConfig", "Duplicate current config"),
        Desc = "Create a copy using the target config name",
        Icon = "copy",
        ButtonText = "Duplicate",
        Callback = function()
            local ok, message = self:DuplicateConfig(self.Config.FileName, targetName:Get())
            self:Notify({ Title = ok and "Config duplicated" or "Duplicate failed", Content = tostring(message), Type = ok and "Success" or "Error" })
        end,
    })
    section:AddButton({
        Title = self:T("RenameConfig", "Rename current config"),
        Desc = "Rename the current config to the target name",
        Icon = "file-pen-line",
        ButtonText = "Rename",
        Callback = function()
            self:Confirm({
                Title = "Rename config?",
                Content = "Rename '" .. self.Config.FileName .. "' to '" .. tostring(targetName:Get()) .. "'?",
                ConfirmText = "Rename",
                Callback = function(confirmed)
                    if not confirmed then return end
                    local ok, message = self:RenameConfig(self.Config.FileName, targetName:Get())
                    self:Notify({ Title = ok and "Config renamed" or "Rename failed", Content = tostring(message), Type = ok and "Success" or "Error" })
                end,
            })
        end,
    })
    section:AddButton({
        Title = self:T("ExportConfig", "Export current config"),
        Desc = "Put the current config JSON into the text area",
        Icon = "upload",
        ButtonText = "Export",
        Callback = function()
            local ok, content = self:ExportConfig(self.Config.FileName)
            if ok then transfer:Set(content, true) end
            self:Notify({ Title = ok and "Config exported" or "Export failed", Content = ok and self.Config.FileName or tostring(content), Type = ok and "Success" or "Error" })
        end,
    })
    section:AddButton({
        Title = self:T("ImportConfig", "Import as target config"),
        Desc = "Write the text area JSON as the target config name",
        Icon = "download",
        ButtonText = "Import",
        Callback = function()
            local ok, message = self:ImportConfig(transfer:Get(), targetName:Get())
            self:Notify({ Title = ok and "Config imported" or "Import failed", Content = tostring(message), Type = ok and "Success" or "Error" })
        end,
    })
    return section
end

local v2OriginalAddConfigSection = WindowMethods.AddConfigSection
function WindowMethods:AddConfigSection(tab, options)
    options = options or {}
    local section = v2OriginalAddConfigSection(self, tab, options)
    if options.IncludeAdvanced ~= false then
        self:AddAdvancedConfigSection(tab, options.AdvancedOptions)
    end
    return section
end

function WindowMethods:SetSidebarOpen(value)
    if not self.MobileDrawerEnabled or not self.Sidebar or not self.Content then
        return
    end
    self.SidebarOpen = value == true
    local width = self.Sidebar.Size.X.Offset
    tween(self.Sidebar, 0.2, {
        Position = self.SidebarOpen and UDim2.fromOffset(0, 0) or UDim2.fromOffset(-width - 8, 0),
    }, Enum.EasingStyle.Quint)
    if self.MobileScrim then
        self.MobileScrim.Visible = self.SidebarOpen
        self.MobileScrim.BackgroundTransparency = self.SidebarOpen and 0.45 or 1
    end
end

function WindowMethods:ToggleSidebar()
    self:SetSidebarOpen(not self.SidebarOpen)
end

function WindowMethods:_InitializeProSuite(options)
    options = options or {}
    self._Connections = self._Connections or {}
    self._CleanupCallbacks = self._CleanupCallbacks or {}
    self._SearchEntries = self._SearchEntries or {}
    self.MaxNotifications = tonumber(options.MaxNotifications) or 4
    self.SearchEnabled = options.SearchEnabled ~= false
    self.SearchQuery = ""

    local content = self.PageContainer and self.PageContainer.Parent
    local sidebar = self.TabList and self.TabList.Parent
    self.Content = content
    self.Sidebar = sidebar

    local tooltip = create("CanvasGroup", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(280, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        GroupTransparency = 1,
        Parent = self.ScreenGui,
        ZIndex = 700,
    })
    corner(tooltip, 9)
    stroke(tooltip, Theme.Border, 0.18, 1)
    padding(tooltip, 10, 10, 7, 7)
    local tooltipLabel = create("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        FontFace = fontFace("Regular"),
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = fontSize(11),
        TextWrapped = true,
        Parent = tooltip,
        ZIndex = 701,
    })
    local maxSize = create("UISizeConstraint", {
        MaxSize = Vector2.new(320, 180),
        Parent = tooltip,
    })
    self.TooltipFrame = tooltip
    self.TooltipLabel = tooltipLabel

    if content and self.SearchEnabled then
        local searchFrame = create("Frame", {
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(22, 64),
            Size = UDim2.new(1, -44, 0, 36),
            Parent = content,
            ZIndex = 8,
        })
        corner(searchFrame, 11)
        local searchIcon = createIcon(searchFrame, "search", 16, Theme.TextMuted, 9)
        searchIcon.Frame.Position = UDim2.fromOffset(12, 10)
        local searchBox = create("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            FontFace = fontFace("Regular"),
            PlaceholderText = options.SearchPlaceholder or self:T("SearchControls", "Search controls..."),
            PlaceholderColor3 = Theme.TextDim,
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = fontSize(11),
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(39, 0),
            Size = UDim2.new(1, -77, 1, 0),
            Parent = searchFrame,
            ZIndex = 9,
        })
        local clear = createTextButton({
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -34, 0, 0),
            Size = UDim2.fromOffset(34, 36),
            Text = "×",
            TextColor3 = Theme.TextMuted,
            TextSize = fontSize(15),
            Parent = searchFrame,
            ZIndex = 9,
        })
        self.SearchFrame = searchFrame
        self.SearchBox = searchBox
        self:_TrackConnection(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            self:ApplySearch(searchBox.Text)
        end))
        self:_TrackConnection(clear.MouseButton1Click:Connect(function()
            searchBox.Text = ""
        end))
        self.PageContainer.Position = UDim2.fromOffset(22, 110)
        self.PageContainer.Size = UDim2.new(1, -44, 1, -110)
    end

    local mobileLayout = tostring(options.MobileLayout or "Drawer")
    if self.MobileMode and mobileLayout:lower() ~= "classic" and sidebar and content then
        self.MobileDrawerEnabled = true
        self.SidebarOpen = false
        local width = sidebar.Size.X.Offset
        content.Position = UDim2.fromOffset(0, 0)
        content.Size = UDim2.fromScale(1, 1)
        sidebar.Position = UDim2.fromOffset(-width - 8, 0)
        sidebar.ZIndex = 30

        local scrim = create("TextButton", {
            AutoButtonColor = false,
            Text = "",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = self.Body,
            ZIndex = 25,
        })
        self.MobileScrim = scrim
        self:_TrackConnection(scrim.MouseButton1Click:Connect(function()
            self:SetSidebarOpen(false)
        end))

        local menuButton = createTextButton({
            BackgroundColor3 = Theme.Surface2,
            Position = UDim2.fromOffset(55, 13),
            Size = UDim2.fromOffset(34, 34),
            Parent = self.Topbar,
            ZIndex = 12,
        })
        corner(menuButton, 10)
        local menuIcon = createIcon(menuButton, "menu", 17, Theme.TextMuted, 13)
        menuIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        menuIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)
        self.MobileMenuButton = menuButton
        self:_TrackConnection(menuButton.MouseButton1Click:Connect(function()
            self:ToggleSidebar()
        end))

        for _, child in ipairs(self.Topbar:GetChildren()) do
            if child:IsA("TextLabel") and child.Position.X.Offset >= 58 then
                child.Position = UDim2.new(child.Position.X.Scale, child.Position.X.Offset + 40, child.Position.Y.Scale, child.Position.Y.Offset)
                child.Size = UDim2.new(child.Size.X.Scale, child.Size.X.Offset - 40, child.Size.Y.Scale, child.Size.Y.Offset)
            end
        end
    end
end

local v2OriginalCreateWindow = VoltzUI.CreateWindow
function VoltzUI:CreateWindow(options)
    options = options or {}
    local window = v2OriginalCreateWindow(self, options)
    window:_InitializeProSuite(options)
    window:_InitializeTouchInputGuard()
    return window
end

local v2InputGuardOriginalSetVisible = WindowMethods.SetVisible
function WindowMethods:SetVisible(value)
    v2InputGuardOriginalSetVisible(self, value)
    if not self.Visible then
        self:_ClearActiveUITouches()
    end
end

local v2OriginalSelectTab = WindowMethods.SelectTab
function WindowMethods:SelectTab(tab)
    v2OriginalSelectTab(self, tab)
    if self.SearchEnabled then
        self:ApplySearch(self.SearchQuery or "", tab)
    end
    if self.MobileDrawerEnabled and self.SidebarOpen then
        self:SetSidebarOpen(false)
    end
end

local v2OriginalClose = WindowMethods.Close
function WindowMethods:Close()
    if self._Closing then return end
    for _, connection in ipairs(self._Connections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    self._Connections = {}
    for _, callback in ipairs(self._CleanupCallbacks or {}) do
        pcall(callback)
    end
    self._CleanupCallbacks = {}
    v2OriginalClose(self)
end

function WindowMethods:Unload()
    self:Close()
end

function WindowMethods:ReportError(context, message)
    local title = "VoltzUI Error"
    local detail = tostring(context or "Unknown") .. ": " .. tostring(message or "Unknown error")
    warn("[VoltzUI] " .. detail)
    if self.ScreenGui and self.ScreenGui.Parent then
        self:Notify({
            Id = "voltz-error-" .. tostring(context or "unknown"),
            Title = title,
            Content = detail,
            Type = "Error",
            Icon = "triangle-alert",
            Duration = 7,
        })
    end
    return false, detail
end

function WindowMethods:SafeCall(context, callback, ...)
    if type(callback) ~= "function" then
        return self:ReportError(context, "Callback is not a function")
    end
    local args = table.pack(...)
    local results = table.pack(pcall(function()
        return callback(table.unpack(args, 1, args.n))
    end))
    if not results[1] then
        return self:ReportError(context, results[2])
    end
    return true, table.unpack(results, 2, results.n)
end

function WindowMethods:GetControl(flag)
    local data = self.Controls and self.Controls[flag]
    return data and data.Controller or nil
end

function WindowMethods:BindDependency(targetController, sourceController, expected)
    if targetController and type(targetController.DependsOn) == "function" then
        targetController:DependsOn(sourceController, expected)
        return true
    end
    return false, "Target controller does not support dependencies"
end

VoltzUI.Components = VoltzUI.Components or {}
function VoltzUI:RegisterComponent(name, factory)
    assert(type(name) == "string" and name ~= "", "Component name is required")
    assert(type(factory) == "function", "Component factory must be a function")
    self.Components[name] = factory
    return self
end

VoltzUI.RegisterPlugin = VoltzUI.RegisterComponent

function SectionMethods:AddComponent(name, options)
    local factory = VoltzUI.Components[name]
    assert(type(factory) == "function", "Unknown VoltzUI component: " .. tostring(name))
    return factory(self, options or {}, VoltzUI)
end


-- Friendly aliases: both AddButton(...) and Button(...) styles are supported.
WindowMethods.CreateTab = WindowMethods.AddTab
WindowMethods.Notification = WindowMethods.Notify
WindowMethods.ConfigSection = WindowMethods.AddConfigSection
WindowMethods.ThemeSection = WindowMethods.AddThemeSection
WindowMethods.LanguageSection = WindowMethods.AddLanguageSection
WindowMethods.SetVisibility = WindowMethods.SetVisible
TabMethods.CreateSection = TabMethods.AddSection
SectionMethods.Button = SectionMethods.AddButton
SectionMethods.Toggle = SectionMethods.AddToggle
SectionMethods.Slider = SectionMethods.AddSlider
SectionMethods.Dropdown = SectionMethods.AddDropdown
SectionMethods.Input = SectionMethods.AddInput
SectionMethods.Keybind = SectionMethods.AddKeybind
SectionMethods.Paragraph = SectionMethods.AddParagraph
SectionMethods.Divider = SectionMethods.AddDivider
SectionMethods.TextArea = SectionMethods.AddTextArea
SectionMethods.ColorPicker = SectionMethods.AddColorPicker
SectionMethods.Status = SectionMethods.AddStatus
SectionMethods.List = SectionMethods.AddList
SectionMethods.Component = SectionMethods.AddComponent
WindowMethods.ThemeEditor = WindowMethods.AddThemeEditor
WindowMethods.AdvancedConfigSection = WindowMethods.AddAdvancedConfigSection

VoltzUI.Theme = Theme
VoltzUI.ThemePresets = ThemeDefinitions
VoltzUI.LanguagePresets = LanguageDefinitions
VoltzUI.LoadIcons = loadExternalIcons
VoltzUI.SetFontFamily = VoltzUI.SetFont
VoltzUI.SetTypographyScale = VoltzUI.SetFontScale

return VoltzUI
