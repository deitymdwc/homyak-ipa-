extends Control

# Основные переменные прогресса
var coins: int = 0
var coins_per_click: int = 1
var passive_income: int = 0

# Идентификатор текущего выбранного скина
var current_skin_id: String = "default"

# Список всех скинов и их параметров
var skins: Array[Dictionary] = [
	{
		"id": "default",
		"name": "Дефолт",
		"price": 0,
		"bonus_passive": 0,
		"bonus_click": 0,
		"unlocked": true,
		"texture_path": "res://assets/skins/default.jpg" # Путь к вашей картинке
	},
	{
		"id": "litvin",
		"name": "Литвин",
		"price": 1000,
		"bonus_passive": 100,
		"bonus_click": 0,
		"unlocked": false,
		"texture_path": "res://assets/skins/litvin.jpg"
	},
	{
		"id": "pozzy",
		"name": "Поззи",
		"price": 15000,
		"bonus_passive": 450,
		"bonus_click": 0,
		"unlocked": false,
		"texture_path": "res://assets/skins/pozzy.jpg"
	},
	{
		"id": "mellstroy",
		"name": "Меллстрой",
		"price": 25000,
		"bonus_passive": 1000,
		"bonus_click": 100,
		"unlocked": false,
		"texture_path": "res://assets/skins/mellstroy.jpg"
	},
	{
		"id": "stariy_bog",
		"name": "Старый Бог",
		"price": 50000,
		"bonus_passive": 5000,
		"bonus_click": 500,
		"unlocked": false,
		"texture_path": "res://assets/skins/stariy_bog.jpg"
	},
	{
		"id": "homyak",
		"name": "Хомяк",
		"price": 1000000,
		"bonus_passive": 50000,
		"bonus_click": 1500,
		"unlocked": false,
		"texture_path": "res://assets/skins/homyak.jpg"
	}
]

# Стоимость улучшений
# Текущий уровень каждого апгрейда
var click_upgrade_level: int = 0
var passive_upgrade_level: int = 0

# Базовый бонус (который умножается)
var base_click_bonus: int = 1
var base_passive_bonus: int = 2

# Цены
var click_upgrade_cost: int = 10
var passive_upgrade_cost: int = 20

# Путь к файлу сохранения
const SAVE_PATH = "user://save_data.cfg"

# Ссылки на узлы
@onready var coins_label: Label = $CoinsLabel
@onready var passive_income_label: Label = $PassiveIncomeLabel
@onready var click_upgrade_button: Button = $ClickUpgradeButton
@onready var passive_upgrade_button: Button = $PassiveUpgradeButton
@onready var music_toggle_button: Button = $MusicToggleButton
@onready var passive_timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	load_game() # Загружаем данные при старте
	update_ui()
	audio_stream_player.play()
	
	passive_timer.timeout.connect(_on_passive_timer_timeout)
	passive_timer.start(1.0) # Запуск секундомера

func get_current_click_bonus() -> int:
	var multiplier = pow(2, int(click_upgrade_level / 5))
	return base_click_bonus * multiplier

func get_current_passive_bonus() -> int:
	var multiplier = pow(2, int(passive_upgrade_level / 5))
	return base_passive_bonus * multiplier
# Нажатие на главную кнопку
func _on_click_button_pressed() -> void:
	coins += coins_per_click
	update_ui()
	animate_click()

# Прокачка силы клика (+1 к клику)
func _on_click_upgrade_button_pressed() -> void:
	if coins >= click_upgrade_cost:
		coins -= click_upgrade_cost
		
		# Прибавляем бонус с учетом всех удвоений
		coins_per_click += get_current_click_bonus()
		click_upgrade_level += 1
		
		# Увеличиваем цену
		click_upgrade_cost = int(click_upgrade_cost * 1.2)
		
		update_ui()
		save_game()

# Прокачка пассивного дохода (+2/сек)
func _on_passive_upgrade_button_pressed() -> void:
	if coins >= passive_upgrade_cost:
		coins -= passive_upgrade_cost
		
		# Прибавляем бонус с учетом всех удвоений
		passive_income += get_current_passive_bonus()
		passive_upgrade_level += 1
		
		# Увеличиваем цену
		passive_upgrade_cost = int(passive_upgrade_cost * 1.3)
		
		update_ui()
		save_game()

# Начисление пассивного дохода каждую секунду
func _on_passive_timer_timeout() -> void:
	coins += passive_income
	update_ui()
	save_game() # Сохраняем прогресс каждую секунду

# --- Интерфейс и Анимация ---

func update_ui() -> void:
	coins_label.text = "Монеты: " + str(coins)
	passive_income_label.text = "Пассивный доход: +" + str(passive_income) + "/сек"
	
	click_upgrade_button.text = "Сила клика +" + str(get_current_click_bonus()) + \
		" [Ур. " + str(click_upgrade_level) + "] (Цена: " + str(click_upgrade_cost) + ")"
		
	passive_upgrade_button.text = "Пассивка +" + str(get_current_passive_bonus()) + \
		"/сек [Ур. " + str(passive_upgrade_level) + "] (Цена: " + str(passive_upgrade_cost) + ")"
	

# --- Система Сохранений (ConfigFile) ---

func save_game() -> void:
	var config = ConfigFile.new()
	
	# Основные переменные
	config.set_value("Player", "coins", coins)
	config.set_value("Player", "coins_per_click", coins_per_click)
	config.set_value("Player", "passive_income", passive_income)
	config.set_value("Player", "current_skin_id", current_skin_id)
	
	# Сохраняем ТЕКУЩУЮ ЦЕНУ базовых апгрейдов
	config.set_value("Upgrades", "click_upgrade_cost", click_upgrade_cost)
	config.set_value("Upgrades", "passive_upgrade_cost", passive_upgrade_cost)
	
	config.set_value("Upgrades", "click_upgrade_level", click_upgrade_level)
	config.set_value("Upgrades", "passive_upgrade_level", passive_upgrade_level)
	
	# Статус купленных скинов
	for skin in skins:
		config.set_value("Skins", skin["id"], skin["unlocked"])
		
	config.save(SAVE_PATH)

func select_or_buy_skin(skin_id: String) -> void:
	for skin in skins:
		if skin["id"] == skin_id:
			# Если скин уже куплен — просто надеваем его
			if skin["unlocked"]:
				equip_skin(skin)
				return
			
			# Если скин не куплен — проверяем баланс и покупаем
			if coins >= skin["price"]:
				coins -= skin["price"]
				skin["unlocked"] = true
				
				# Добавляем бонусы скина к показателям
				passive_income += skin["bonus_passive"]
				coins_per_click += skin["bonus_click"]
				
				equip_skin(skin)
				save_game()
				update_ui()
			else:
				print("Не хватает монет!")
			return

# Применение скина (меняем текстуру главному хомяку)
func equip_skin(skin: Dictionary) -> void:
	current_skin_id = skin["id"]
	var path: String = skin["texture_path"]
	
	# ResourceLoader корректно работает внутри APK на Android
	if ResourceLoader.exists(path):
		var texture = load(path)
		
		# Автоматически проверяем тип кнопки
		if $TextureButton is TextureButton:
			$TextureButton.texture_normal = texture
		elif $TextureButton is Button:
			$TextureButton.icon = texture
	else:
		push_error("Не удалось найти скин на Android по пути: " + path)
	
	save_game()
	update_ui()

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return # Если сохранения нет, остаются дефолтные значения
	
	# Загружаем показатели игрока
	coins = config.get_value("Player", "coins", 0)
	coins_per_click = config.get_value("Player", "coins_per_click", 1)
	passive_income = config.get_value("Player", "passive_income", 0)
	current_skin_id = config.get_value("Player", "current_skin_id", "default")
	click_upgrade_level = config.get_value("Upgrades", "click_upgrade_level", 0)
	passive_upgrade_level = config.get_value("Upgrades", "passive_upgrade_level", 0)
	# Загружаем сохраненную СТОИМОСТЬ апгрейдов (с дефолтными значениями, если их не было)
	click_upgrade_cost = config.get_value("Upgrades", "click_upgrade_cost", 10)
	passive_upgrade_cost = config.get_value("Upgrades", "passive_upgrade_cost", 20)
	
	# Загружаем купленные скины
	for skin in skins:
		skin["unlocked"] = config.get_value("Skins", skin["id"], skin["id"] == "default")
		if skin["id"] == current_skin_id:
			equip_skin(skin)
			
	update_ui()

# Сохранение при выходе из игры (на ПК или мобильных устройствах)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
		
# Вызывай эту функцию внутри _on_click_button_pressed()
func animate_click() -> void:
	var button = $TextureButton # Переменная вашей главной TextureButton
	
	# Сбрасываем масштаб и угол, чтобы при частых кликах кнопка не "улетала"
	button.rotation_degrees = 0
	button.scale = Vector2(1.0, 1.0)
	
	var tween = create_tween().set_parallel(true)
	
	# 1. Сжатие и отскок (Scale)
	tween.tween_property(button, "scale", Vector2(0.85, 0.85), 0.03)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.08)\
		.set_delay(0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# 2. Рандомный наклон вправо/влево (Rotation)
	var random_angle = randf_range(-8.0, 8.0)
	tween.tween_property(button, "rotation_degrees", random_angle, 0.03)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "rotation_degrees", 0.0, 0.08)\
		.set_delay(0.03).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_music_toggle_button_pressed() -> void:
	# Проверяем, активен ли режим Toggle (нажата ли кнопка)
	if music_toggle_button.button_pressed:
		music_toggle_button.text = "ВКЛ РЕП ПРО ТВИРИКА 2026"
		audio_stream_player.stop()
	else:
		music_toggle_button.text = "ВЫКЛ РЕП ПРО ТВИРИКА 2026"
		audio_stream_player.play()
		

func _on_btn_default_pressed() -> void:
	select_or_buy_skin("default")

func _on_btn_litvin_pressed() -> void:
	select_or_buy_skin("litvin")

func _on_btn_pozzy_pressed() -> void:
	select_or_buy_skin("pozzy")

func _on_btn_mellstroy_pressed() -> void:
	select_or_buy_skin("mellstroy")

func _on_btn_stariy_bog_pressed() -> void:
	select_or_buy_skin("stariy_bog")

func _on_btn_homyak_pressed() -> void:
	select_or_buy_skin("homyak")
