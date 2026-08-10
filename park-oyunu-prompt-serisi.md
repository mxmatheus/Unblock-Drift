# İki Fazlı Park Oyunu — Godot 4.7.1 Prompt Serisi

**Motor:** Godot 4.7.1
**Konsept:** Faz 1 — grid tabanlı sliding puzzle (arabaları hareket ettirerek yol aç). Faz 2 — top-down araç fiziği, el freni ile park yüzdesine göre skorlama.

Bu doküman iki bölümden oluşuyor: **Faz 0 (Asset Üretimi)** görsel üretim AI'larına (Midjourney, DALL-E, vs.) verilecek promptlar; **Faz 1-11 (Geliştirme)** ise Godot projesini kuracak agent'a (Claude Code vb.) sırayla verilecek promptlar. Her prompt bağımsız yürütülebilir şekilde yazıldı, önceki prompt'ların çıktısını referans alır.

---

## FAZ 0 — ASSET ÜRETİMİ (Tasarım Fazı)

### Stil Çapası
Aşağıdaki her prompt'un sonuna bu stil tanımını ekle (tutarlılık için):

> *Top-down 2D pixel art, clean bold outlines, moderate pixel density (~40-60px per unit), saturated flat colors with subtle cel-shading, soft drop shadow beneath, transparent background, centered in canvas, matching the visual style of a mobile parking puzzle game.*

### Prompt 0.1 — Araç Sprite Sheet
**Durum: Elde mevcut** (`cars_sprite_sheet`). Referans olarak kullanılacak — sonraki tüm asset promptlarına bu sprite sheet'in stil örneği olarak verilmesi gerekiyor (görsel üretim aracına referans görsel olarak yükle).

**ÖNEMLİ — Değişken boyut kuralı:** Araçlar gerçekçi oranlarda **farklı boyutlarda** olacak. Sabit tek bir tuval boyutuna zorlamıyoruz. Bunun yerine her araç kendi gerçek en-boy oranını korusun, ama hepsi **aynı grid birimine (örn. 1 hücre = 64px)** göre ölçeklenmiş olsun:
- Spor araba / sedan / taksi / polis → 1x2 hücre (dikey park pozisyonunda)
- Van / pickup → 1x2.5 hücre
- İtfaiye / uzun kamyon / otobüs → 1x3 veya 1x4 hücre

Eğer ek araç tipi gerekirse, aynı stil çapasıyla şu prompt kullanılabilir:
> *Top-down 2D pixel art vehicle sprite: [ARAÇ TİPİ, örn: "long school bus" / "delivery van" / "small sports car"], proportional length relative to a standard sedan (sedan = 2 grid units long), [stil çapası].*

### Prompt 0.2 — Zemin / Park Alanı Tileset
> *Top-down 2D pixel art parking lot tileset: asphalt texture tile, white parking space line markings (straight and angled variants), curb/sidewalk edge tile, entrance/exit arrow marking, grid-aligned to 64px tile size. Seamless tileable where applicable, muted gray asphalt tone with bright white/yellow line accents. [stil çapası]*

### Prompt 0.3 — Engel / Dekor Objeleri
> *Top-down 2D pixel art set of static parking lot obstacles, each sized relative to the 64px grid unit: traffic cone (0.5x0.5 unit), striped barrier/barricade (1x0.3 unit), trash can (0.5x0.5 unit), small planter/bush (0.7x0.7 unit), parking sign post (0.4x0.4 unit). Each object centered on its own transparent canvas. [stil çapası]*

### Prompt 0.4 — UI İkon Seti
> *Flat mobile game UI icon set, top-down parking game theme: handbrake button icon, move-counter icon (arrows), filled star, empty star outline, replay/retry icon, next-level arrow, pause icon, settings gear icon. Rounded flat design, thick outlines, bright saturated colors matching a playful arcade car game, transparent background, each icon on its own square canvas, consistent icon grid size (e.g. 128x128).*

### Prompt 0.5 — Efekt Sprite'ları
> *2D pixel art particle/effect sprite sheet for a top-down car game: tire skid mark streak (horizontal strip, tileable), small dust cloud puff (3-4 frame animation), sparkle/confetti burst for successful parking (4-5 frame animation), exclamation mark collision indicator (single frame). Transparent background, bold saturated colors. [stil çapası]*

**Not:** Faz 0.2–0.5 tamamlandığında hepsini `assets/` altında alt klasörlere ayır: `assets/vehicles/`, `assets/tileset/`, `assets/obstacles/`, `assets/ui/`, `assets/effects/`. Geliştirme fazı promptları bu klasör yapısını referans alacak.

---

## FAZ 1 — PROJE İSKELETİ

**Prompt 1:**
```
Godot 4.7.1 projesi kur. İki fazlı bir top-down 2D park oyunu geliştireceğiz:
Faz 1 = grid tabanlı sliding puzzle (arabaları kaydırarak yol açma)
Faz 2 = top-down araç fiziği ile park etme (el freni mekaniği)

Klasör yapısı oluştur:
- scenes/ (main_menu, level_select, phase1, phase2, ui)
- scripts/ (autoload'lar dahil)
- assets/ (vehicles, tileset, obstacles, ui, effects — mevcut asset'leri buraya organize et)
- resources/ (level_data için Resource script'leri)

Autoload (singleton) script'leri oluştur:
- GameManager.gd: aktif seviye, mevcut faz, genel oyun durumu
- LevelData.gd: seviye verilerini yükleme/parse etme
- SaveSystem.gd: ilerleme kaydetme (JSON tabanlı, user:// dizini)
- AudioManager.gd: ses/müzik yönetimi (şimdilik placeholder fonksiyonlar yeterli)

project.godot ayarlarını mobil dikey oyun için yapılandır (portrait orientation,
uygun viewport/stretch ayarları — mobile stretch mode "canvas_items", 
aspect "keep").

Boş ama çalışır durumda bir MainMenu sahnesi oluştur (sadece "Play" butonu,
GameManager üzerinden Phase1 sahnesine yönlendirsin — şimdilik boş sahne olabilir).
```

**Prompt 2:**
```
Grid tabanlı veri modeli oluştur. Faz 1'deki puzzle mantığı ve Faz 2'deki
spawn/rota belirleme için ortak kullanılacak.

VehicleData Resource sınıfı oluştur (Resource script, .tres olarak
kaydedilebilir):
- vehicle_id: String
- sprite_texture: Texture2D
- grid_size: Vector2 (örn. Vector2(1,2) sedan için, Vector2(1,3) itfaiye için — 
  1 birim = 64px olacak şekilde)
- vehicle_type: enum (SEDAN, TRUCK, VAN, SPORTS, EMERGENCY) — ileride farklı
  fizik/skorlama davranışları için kullanılabilir

GridSystem.gd script'i oluştur (Faz 1 sahnesine ait):
- Grid boyutu parametrik olsun (örn. 6x8 hücre, seviyeye göre değişebilir)
- Her hücrenin dolu/boş durumunu tutan 2D array
- Bir aracın grid_size'ına göre (1x1'den büyük olabilir) birden fazla hücreyi
  kaplayabilmesi mantığı
- Bir aracın yatay/dikey eksende ne kadar kayabileceğini hesaplayan fonksiyon
  (bloke eden başka araç veya grid sınırına kadar)

Şimdilik test amaçlı: 3-4 farklı boyutta placeholder araç (mevcut
cars_sprite_sheet'ten) grid üzerine yerleştir, konsola grid durumunu
yazdıran bir debug fonksiyonu ekle.
```

---

## FAZ 2 — FAZ 1 ÇEKİRDEK MEKANİĞİ (Puzzle)

**Prompt 3:**
```
Faz 1 puzzle mekaniğini tamamla. Önceki prompt'ta kurulan GridSystem
üzerine inşa et.

Vehicle sahnesi oluştur (Node2D + Sprite2D + Area2D/collision):
- Sadece kendi ekseni doğrultusunda (yatay araç sadece yatay, dikey araç
  sadece dikey) kaydırılabilir — klasik sliding block puzzle kuralı
- Tıkla-sürükle (drag) input ile hareket, GridSystem'in hesapladığı
  maksimum kayma mesafesini aşamaz
- Hareket bittiğinde otomatik olarak en yakın geçerli grid pozisyonuna
  "snap" olsun (yumuşak tween ile)

Hareket hakkı sistemi:
- Level başına sabit "moves_remaining" sayacı (level data'dan gelecek)
- Her başarılı sürükleme hareketinde sayaç azalsın (aynı yönde devam eden
  tek bir sürükleme = 1 hareket, ileri geri gitme serbest ama bırakınca sayılsın)
- Sayaç HUD'da gösterilsin (0.4 UI ikon setinden move-counter ikonu kullan)
- Sayaç 0 olduğunda ve hedef araç hâlâ çıkışa ulaşmadıysa "reklam izle,
  +3 hareket kazan" popup'ı tetikle (şimdilik placeholder buton, gerçek
  reklam SDK'sı sonraki bir prompt'ta eklenecek)

Hedef araç (oyuncunun park edeceği/çıkaracağı araç) görsel olarak
vurgulansın (örn. hafif glow/outline shader veya farklı renk tint).

Çıkış noktasına ulaşan hedef araç grid'den kayboluşunda (fade out +
scale animasyonu) Faz 1 → Faz 2 geçiş sinyalini (Godot signal) tetiklesin.
```

**Prompt 4:**
```
Level data sistemi ve çözülebilirlik kontrolü ekle.

LevelResource.gd (Resource) sınıfı oluştur:
- grid_width, grid_height: int
- vehicles: Array[Dictionary] (her biri: vehicle_type, grid_size, 
  start_position, orientation)
- target_vehicle_id: String
- moves_allowed: int
- exit_position: Vector2 / exit_direction
- phase2_config: Dictionary (park alanı boyutu, hedef açı, araç hızı — 
  Faz 2 için, sonraki prompt'ta detaylandırılacak)

10 örnek seviye oluştur (.tres dosyaları), kolaydan zora artan zorlukta:
- İlk 3 seviye: 4x4 grid, 2-3 araç, bol hareket hakkı (öğretici)
- Orta 4 seviye: 5x6 grid, 4-6 araç, sınırlı hareket hakkı
- Son 3 seviye: 6x8 grid, 6-8 araç (bazıları çok hücreli/büyük), sıkı
  hareket hakkı

Basit bir çözülebilirlik doğrulama script'i yaz (editör içi tool script
veya ayrı bir test sahnesi): her seviyeyi otomatik BFS/simülasyon ile
çözüp "bu seviye moves_allowed hakkı içinde çözülebilir mi" kontrolü
yapsın, konsola sonuç yazdırsın. Çözülemeyen varsa uyarı versin.
```

---

## FAZ 3 — GEÇİŞ SİSTEMİ

**Prompt 5:**
```
Faz 1 → Faz 2 geçiş sistemini kur.

TransitionManager.gd (autoload veya GameManager içine entegre) oluştur:
- Faz 1'de hedef aracın çıkışa ulaştığı açı/pozisyon bilgisini al
- Bu bilgiyi Faz 2 sahnesine "başlangıç rotası/pozisyonu" olarak aktar
  (GameManager üzerinden veri taşı)

Geçiş animasyonu:
- Kamera kısa bir zoom-in/pan yapsın (Faz 1 grid görünümünden Faz 2'nin
  başlangıç noktasına odaklanan bir geçiş, ~1-1.5 saniye)
- Basit bir "loading" veya sahne değiştirme fade efekti (ColorRect ile
  fade to black / fade in, get_tree().change_scene_to_file kullan)
- Faz 2 sahnesi yüklendiğinde, aktarılan level_data'nın phase2_config
  bilgisine göre araç ve park alanı doğru pozisyon/açıda spawn olsun
```

---

## FAZ 4 — FAZ 2 ÇEKİRDEK MEKANİĞİ (Park Fiziği)

**Prompt 6:**
```
Faz 2 araç fiziğini kur. RigidBody2D tabanlı top-down araç kontrolü.

PlayerCar sahnesi (RigidBody2D + Sprite2D + collision shape):
- Sürekli otomatik ileri ivmelenme (sabit bir hedef hıza kadar)
- Tek input: el freni butonu (basılı tutulduğunda ani friction/angular
  damping artışı — araç kayarak yavaşlasın ve rotasyonu daha az kontrol
  edilebilir hale gelsin, "drift" hissi versin)
- linear_damp ve angular_damp değerlerini el freni durumuna göre
  runtime'da değiştir
- Ekran sınırları veya duvar objelerine çarpma durumunda basit bir
  "seviye başarısız" tetikleyici (opsiyonel, ilk versiyonda es geçilebilir)

ParkingSpot Area2D oluştur:
- Belirli bir pozisyon, boyut ve hedef açı (rotation) bilgisi olsun
- Level data'daki phase2_config'ten gelen değerlere göre spawn olsun

Kontrol şeması basit tutulsun: tek dokunma/tık = el freni aktif,
bırakınca normal sürüş. Mobilde tek parmakla oynanabilir olmalı.
```

**Prompt 7:**
```
Park doğruluk skorlama sistemini ekle.

Araç ParkingSpot alanına girdiğinde ve oyuncu duraksadığında (hız belirli
bir eşiğin altına düştüğünde) şu hesaplamayı yap:
- Aracın collision shape'i ile ParkingSpot alanının kesişim (overlap)
  yüzdesi
- Aracın rotasyonu ile ParkingSpot'un hedef rotasyonu arasındaki açı farkı
- İkisini ağırlıklı birleştirip 0-100 arası bir "park skoru" üret
  (örn. %70 overlap ağırlığı + %30 açı hizası ağırlığı — bu oranı
  ayarlanabilir yap)

Skor eşiklerine göre yıldız sistemi:
- %85+ = 3 yıldız
- %60-84 = 2 yıldız
- %35-59 = 1 yıldız
- %35 altı = 0 yıldız / seviye tekrar dene ekranı

Sonuç ekranı (level complete UI): kazanılan yıldızlar (0.4 UI setindeki
star ikonları), park skoru yüzdesi büyük punto ile, "sonraki seviye" ve
"tekrar dene" butonları. Skor gösterimi sırasında 0.5'teki confetti/sparkle
efektini tetikle (3 yıldız için).
```

---

## FAZ 5 — İLERLEME VE ZORLUK EĞRİSİ

**Prompt 8:**
```
Seviye ilerleme ve zorluk eğrisi sistemini kur.

LevelSelect sahnesi:
- Tüm seviyeleri grid/liste halinde göster
- Kazanılan yıldız sayısını her seviye kartında göster
- Bir sonraki seviye kilidi, önceki seviyenin en az 1 yıldızla
  tamamlanmasına bağlı olsun (SaveSystem üzerinden kontrol)

Zorluk eğrisi parametrelerini belgele (level_data .tres dosyalarına
yansıt):
- Faz 1: seviye ilerledikçe grid boyutu büyüsün, araç sayısı artsın,
  moves_allowed oranı sıkılaşsın (çözüm için gereken minimum harekete
  oranla giderek daha az fazlalık hakkı)
- Faz 2: seviye ilerledikçe park alanı boyutu küçülsün, araç otomatik
  hızı artsın, bazı seviyelerde park alanı açısı daha zorlu (çapraz/dar
  köşe) olsun

SaveSystem.gd'yi genişlet: her seviye için en yüksek yıldız/skor kalıcı
olarak saklansın (JSON, user:// dizininde).
```

---

## FAZ 6 — MONETİZASYON

**Prompt 9:**
```
Reklam entegrasyon noktalarını hazırla (gerçek SDK entegrasyonu — 
AdMob/Unity Ads plugin kurulumu — ayrı bir adımda ele alınacak, şimdilik
tüm reklam çağrılarını soyutlanmış bir AdManager.gd autoload üzerinden
yap, içi placeholder fonksiyonlarla dolu olsun ama arayüz gerçek SDK
entegrasyonuna hazır olsun):

AdManager.gd:
- show_rewarded_ad(on_success: Callable, on_fail: Callable) fonksiyonu
- Faz 1'de "hareket hakkı bitti" durumunda bu fonksiyonu çağıran UI akışı
- Faz 2'de başarısız park sonrası "tekrar dene hakkı kazan" reklam akışı
- Seviyeler arası interstitial reklam noktası (örn. her 3 seviyede bir,
  placeholder olarak işaretlensin)

Bu prompt'un çıktısı: reklam SDK'sı henüz bağlı değil ama tüm UI akışları
ve çağrı noktaları hazır, SDK eklenince sadece AdManager.gd içindeki
placeholder'lar gerçek SDK çağrılarıyla değiştirilecek.
```

---

## FAZ 7 — POLİSH VE KAYIT

**Prompt 10:**
```
UI/UX polish ("juice") geçişi yap.

- Faz 1'de araç hareket ettirilirken hafif bir "tık" sesi ve minik
  scale-bounce animasyonu (snap anında)
- Faz 2'de el freni basılı tutulurken tire skid efektini (0.5 asset'i)
  aracın arkasında spawn et, dust cloud efektini araç kayarken göster
- Buton basmalarında standart bir scale-down/up feedback animasyonu
  (tüm UI butonlarına uygulanabilir bir reusable script/component olarak)
- Haptic feedback: mobilde el freni basıldığında ve park skoru
  gösterildiğinde Input.vibrate_handheld() çağrısı (kısa, ~50-100ms)
- Basit bir arka plan müziği ve SFX placeholder'ları AudioManager
  üzerinden bağlanmış olsun (gerçek ses dosyaları sonra eklenecek)

Genel UI teması: 0.4'teki ikon setini tüm HUD ve menülerde tutarlı
şekilde kullan, tek bir renk paleti/font seçimiyle sınırla (bunu ayrı
bir "design_system.md" notu olarak da projeye ekle, ileride yeni ekran
eklenirken referans alınsın).
```

**Prompt 11:**
```
Ayarlar ekranı ve genel kayıt sistemi finalizasyonu.

SettingsMenu sahnesi: ses aç/kapa, müzik aç/kapa, titreşim aç/kapa.
Bu tercihler SaveSystem üzerinden kalıcı olsun.

Oyun genelinde bir son test/QA geçişi yap:
- Tüm 10 örnek seviyeyi baştan sona oynanabilirlik açısından kontrol et
- Faz 1 → Faz 2 geçişinde veri kaybı / hatalı spawn olup olmadığını
  kontrol et
- Farklı ekran boyutları için UI'ın (anchor/container kullanımı) doğru
  ölçeklendiğini doğrula
```

---

## Notlar
- Her prompt'u ayrı bir agent oturumunda/mesajında sırayla ver, önceki prompt'un çıktısını (dosya/kod durumu) agent'ın görebildiğinden emin ol.
- Faz 0 (asset üretimi) geliştirme promptlarından bağımsız yürütülebilir — paralel ilerleyebilirsin, ama Prompt 3'e geçmeden önce en azından 0.1 ve 0.2'nin (araçlar + zemin) hazır olması gerekiyor.
- Reklam SDK'sının gerçek entegrasyonu (Prompt 9 sonrası) ayrı ve platform-spesifik (Android/iOS export ayarları dahil) bir prompt serisi gerektirir — istersen ayrı hazırlarız.
