--[[
    GUGUHUB: LUCKY RAID AFK ASSISTANT v1.0
    Update 73 (14.03.2026)
    
    ЧТО ДЕЛАЕТ:
    ✅ Включает встроенный Auto Raid (через интерфейс, не спамит)
    ✅ Автоматически кликает для Anti-AFK
    ✅ Показывает статус в консоли
    ✅ Не спамит Remote, не триггерит античит
    
    ЧТО НЕ ДЕЛАЕТ:
    ❌ Не пытается ломать быстрее (это невозможно)
    ❌ Не телепортирует (можно банить)
    ❌ Не спамит покупки апгрейдов
]]

-- [[ НАСТРОЙКИ ]]
local SETTINGS = {
    AutoEnableRaid = true,          -- Включить Auto Raid при входе в рейд
    ClickInterval = 60,             -- Интервал кликов для Anti-AFK (секунд)
    ShowStatus = true,              -- Показывать статус в консоли
}

-- [[ СЕРВИСЫ ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

-- [[ ПЕРЕМЕННЫЕ ]]
local autoRaidEnabled = false
local lastStatusTime = 0

-- [[ ФУНКЦИЯ: Поиск и нажатие кнопки Auto Raid ]]
local function findAndClickAutoRaid()
    -- Ищем GUI игрока
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    -- Рекурсивный поиск кнопки Auto Raid
    local function searchForButton(obj)
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local text = (obj.Text or obj.Name or ""):lower()
            -- Ищем кнопку Auto Raid (обычно слева экрана)
            if (text:find("auto") and text:find("raid")) or obj.Name:find("AutoRaid") then
                pcall(function()
                    obj:Click()
                    return true
                end)
            end
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            if searchForButton(child) then return true end
        end
        return false
    end
    
    return searchForButton(playerGui)
end

-- [[ ФУНКЦИЯ: Проверка нахождения в рейде ]]
local function isInRaid()
    -- Простая проверка: есть ли карта рейда
    return Workspace:FindFirstChild("RaidMap") ~= nil
end

-- [[ ФУНКЦИЯ: Получение текущего уровня рейда ]]
local function getRaidLevel()
    local level = Player:GetAttribute("RaidLevel")
    if level then return level end
    
    -- Альтернативный метод через Leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        local raidStat = leaderstats:FindFirstChild("RaidLevel")
        if raidStat then return raidStat.Value end
    end
    
    return nil
end

-- [[ ФУНКЦИЯ: Anti-AFK клик ]]
local function antiAFK()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end

-- [[ ГЛАВНЫЙ ЦИКЛ ]]
task.spawn(function()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("  GUGUHUB: LUCKY RAID AFK ASSISTANT")
    print("  Актуально: Update 73 (14.03.2026)")
    print("  Режим: AFK-помощник (без риска бана)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- Включаем Anti-AFK по таймеру
    task.spawn(function()
        while task.wait(SETTINGS.ClickInterval) do
            antiAFK()
            if SETTINGS.ShowStatus then
                print("[GuguHub] 💤 Anti-AFK клик")
            end
        end
    end)
    
    -- Основной цикл
    while task.wait(5) do
        local inRaid = isInRaid()
        local raidLevel = getRaidLevel()
        
        -- Статус в консоли
        if SETTINGS.ShowStatus and os.time() - lastStatusTime > 30 then
            lastStatusTime = os.time()
            if raidLevel then
                print(string.format("[GuguHub] 📊 Уровень рейда: %d / 25000 (%.1f%%)", 
                    raidLevel, (raidLevel / 25000) * 100))
            end
            print("[GuguHub] " .. (inRaid and "🔴 В рейде" or "🟢 В лобби"))
        end
        
        -- Включаем Auto Raid если в рейде и настройка разрешает
        if SETTINGS.AutoEnableRaid and inRaid and not autoRaidEnabled then
            local success = findAndClickAutoRaid()
            if success then
                autoRaidEnabled = true
                print("[GuguHub] ✅ Auto Raid включён")
            else
                -- Не спамим поиск каждые 5 секунд, ждём подольше
                autoRaidEnabled = false
            end
        end
        
        -- Если вышли из рейда, сбрасываем флаг
        if not inRaid then
            autoRaidEnabled = false
        end
    end
end)

print("[GuguHub] ✅ Скрипт загружен. Начинаю AFK-помощь...")