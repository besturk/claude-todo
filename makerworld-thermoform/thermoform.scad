// =====================================================================
//  Thermoform Takımı — MakerWorld Parametric Model Maker
//  Ağsı levha + dişi kalıp + erkek zıpka + asma kapağı + geçme pimler
//  (+ isteğe bağlı göz/ağız oyukları ve parçaları)
//
//  ÖNEMLİ: Ağsı doku modelde değil, dilimleyicidedir.
//  Levhaları Bambu Studio'da nesne bazında şu ayarla basın:
//    Üst kabuk katmanı = 0, Alt kabuk katmanı = 0,
//    Dolgu %30 (gyroid / honeycomb / triangles), katman 0.2 mm.
//  Kalıp ve zıpka PETG basılmalı (PLA levhayı yumuşatan ısıda PLA kalıp da yumuşar).
// =====================================================================

/* [Çıktı] */
// Hangi parça(lar) üretilsin?
parca = "levha_takimi"; // [levha_takimi:Levha takımı (2 levha + kapak + pimler), kalip_takimi:Kalıp takımı (kalıp + zıpka), yuz_takimi:Yüz parçaları (göz + ağız), levha_on:Ön levha, levha_arka:Arka levha, kalip:Dişi kalıp, zipka:Erkek zıpka, kapak:Asma kapağı, pim:Geçme pim, onizleme:Montaj önizlemesi]

/* [Şekil] */
// Silüet
sekil = "kalp"; // [kalp:Kalp, yildiz:Yıldız, daire:Daire, kare:Yuvarlak kare, damla:Damla, yumurta:Yumurta, bulut:Bulut, hayalet:Hayalet, cicek:Çiçek, yaprak:Yaprak]
// Silüetin uzun kenarı (mm)
boy = 100; // [40:1:200]
// Yıldızın iç yarıçap oranı
yildiz_ic_oran = 0.45; // [0.3:0.01:0.7]
// Yıldız / çiçek kol sayısı
kol_sayisi = 5; // [4:1:8]
// Sivri uçları yuvarlama (mm)
uc_yuvarlama = 1.5; // [0:0.1:6]

/* [Levha] */
// Levha kalınlığı = ağsı dokunun derinliği (mm)
kalinlik = 4.0; // [2:0.2:8]
// Levhanın silüetten dışa taşması — kenetlenme kenarı (mm)
kenar = 8.0; // [4:0.5:14]

/* [Kenar delikleri ve geçme pimler] */
// Delik yükseklikleri (silüet boyunun oranı, alttan). Her değer sağda ve solda birer delik açar.
delik_yukseklikleri = [0.3, 0.65];
// Delik çapı (mm)
delik_d = 3.4; // [2.4:0.1:6]
// Kalıp pimi deliğe göre bu kadar ince (mm)
kalip_pim_bosluk = 0.4; // [0.1:0.05:1]
// Geçme pim sıkılık denemeleri (mm, diş tepesi delikten bu kadar kalın). Her değerden bir takım basılır.
pim_sikiliklari = [0.0, 0.15, 0.3];
// Tek pim seçildiğinde sıkılık (mm)
tek_pim_sikilik = 0.15; // [-0.2:0.05:0.6]

/* [Kalıp ve zıpka] */
// Kalıp cidarı / zıpka flanşı genişliği (mm) — kenardan geniş olmalı
duvar = 9.0; // [4:0.5:18]
// Kalıp boşluğunun düz kısmı (mm)
govde = 8.0; // [2:0.5:30]
// Kubbe yüksekliği (mm)
kubbe = 10.0; // [0:0.5:30]
// Kubbenin yanlardan içerlemesi (mm)
kubbe_icerlek = 8.0; // [0:0.5:25]
// Zıpkanın taban flanşı kalınlığı (mm)
flans = 2.0; // [1:0.5:6]
// Kalıp flanş kalınlığı (mm)
taban = 4.0; // [2:0.5:8]
// Zıpka ile kalıp arası = şekillenmiş levha eti (mm)
bosluk = 1.2; // [0.4:0.1:4]
// Kalıp kabuk kalınlığı (mm)
et = 3.0; // [1.6:0.2:6]
// Kubbe basamak yüksekliği (mm) — küçüldükçe pürüzsüz ama yavaş
kubbe_adim = 0.4; // [0.2:0.1:2]

/* [Asma kapağı] */
// Kapak ağız ölçüleri (mm) — ilk baskıda hangisi tutarsa o kullanılır
kapak_agizlari = [3.6, 4.6];
// Tek kapak seçildiğinde kullanılan ağız (mm)
tek_agiz = 3.6; // [1.5:0.1:8]
// Kelepçe et kalınlığı (mm)
kelepce_et = 1.6; // [1:0.1:3]
// Kelepçe derinliği (mm)
kelepce_derinlik = 4.5; // [2:0.5:10]
// Kelepçe uzunluğu (mm)
kelepce_uzunluk = 11.0; // [6:0.5:25]
// Asma halkası dış çapı (mm)
halka_dis = 9.0; // [6:0.5:20]
// Asma deliği çapı (mm)
halka_ic = 5.0; // [2:0.5:12]
// Halka kalınlığı (mm)
halka_et = 3.0; // [2:0.5:6]

/* [Yüz] */
// Ön levhaya göz/ağız oyuğu açılsın mı?
yuz = false;
// Kaç takım göz/ağız basılsın?
yuz_takim = 1; // [1:1:6]
// Göz eni / boyu (mm, boy=100 için; boy ile ölçeklenir)
goz_olcu = [4.4, 10.1];
// Ağız eni / boyu (mm, boy=100 için)
agiz_olcu = [10.5, 3.8];
// Gözlerin yatay aralığı (silüet eninin oranı, merkezden)
goz_aralik = 0.17; // [0.05:0.01:0.35]
// Göz yüksekliği (silüet boyunun oranı, alttan)
goz_yukseklik = 0.62; // [0.3:0.01:0.9]
// Ağız yüksekliği (silüet boyunun oranı, alttan)
agiz_yukseklik = 0.42; // [0.1:0.01:0.8]
// Yüz parçası kalınlığı (mm)
yuz_kalinlik = 3.0; // [1:0.2:6]
// Oyuk, parçadan her kenarda bu kadar büyük (mm)
yuz_tolerans = 0.2; // [0:0.05:0.6]

/* [Hidden] */
$fn = 48;
ARALIK = 6;       // tablada parçalar arası boşluk
TABLA = 256;      // Bambu Lab P2S / X1 / P1 tabla ölçüsü
N = 144;          // silüet örnek sayısı

// ---------------------------------------------------------------- silüetler
function _halka(f) = [for (i = [0:N-1]) f(360 * i / N)];

function sekil_noktalari(ad) =
    ad == "kalp"    ? _halka(function(t) [16*pow(sin(t),3),
                          13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)]) :
    ad == "yildiz"  ? [for (i = [0:2*kol_sayisi-1])
                          let(a = 90 + 180*i/kol_sayisi, r = i%2 ? yildiz_ic_oran : 1)
                          [r*cos(a), r*sin(a)]] :
    ad == "daire"   ? _halka(function(t) [cos(t), sin(t)]) :
    ad == "kare"    ? [for (k = [0:3], j = [0:12])
                          let(a = 90*k + 90*j/12, c = [k==0||k==3 ? 0.8 : -0.8, k<2 ? 0.8 : -0.8])
                          c + 0.2*[cos(a), sin(a)]] :
    ad == "damla"   ? _halka(function(t) [0.75*sin(t)*sin(t/2), cos(t)]) :
    ad == "yumurta" ? _halka(function(t) [0.78*sin(t)*(1 - 0.12*cos(t)), cos(t)]) :
    ad == "bulut"   ? _halka(function(t) let(k = 1 + 0.13*abs(sin(4*t)))
                          [1.35*cos(t)*k, max(-0.55, 0.8*sin(t)*k)]) :
    ad == "hayalet" ? concat(
                          [for (i = [0:48]) let(t = 180*i/48) [cos(t), 0.3 + sin(t)]],
                          [for (i = [0:60]) let(x = -1 + 2*i/60)
                              [x, -0.95 + 0.2*abs(sin((x + 1)/2*3*180))]]) :
    ad == "cicek"   ? _halka(function(t) let(r = 0.62 + 0.38*abs(cos(kol_sayisi*(t - 90)/2)))
                          [r*cos(t), r*sin(t)]) :
    ad == "yaprak"  ? _halka(function(t) [0.5*sin(t)*abs(sin(t)), cos(t)]) :
    _halka(function(t) [cos(t), sin(t)]);

function _min(v, i) = min([for (p = v) p[i]]);
function _max(v, i) = max([for (p = v) p[i]]);

HAM   = sekil_noktalari(sekil);
HAM_G = _max(HAM, 0) - _min(HAM, 0);
HAM_Y = _max(HAM, 1) - _min(HAM, 1);
OLCEK = boy / max(HAM_G, HAM_Y);
MERKEZ = [(_max(HAM, 0) + _min(HAM, 0))/2, (_max(HAM, 1) + _min(HAM, 1))/2];
S_PTS = [for (p = HAM) (p - MERKEZ) * OLCEK];
S_EN  = HAM_G * OLCEK;        // silüet eni (mm)
S_BOY = HAM_Y * OLCEK;        // silüet boyu (mm)
K     = boy / 100;            // yüz ölçek katsayısı

// Silüet, ortalanmış ve boy mm'ye ölçeklenmiş. Sivri uçlar yuvarlanır.
module S() {
    if (uc_yuvarlama > 0)
        offset(r = uc_yuvarlama) offset(delta = -uc_yuvarlama) polygon(S_PTS);
    else
        polygon(S_PTS);
}

// Kenar delikleri: her yükseklikte silüetin sağ kenarı bulunur, kenara dik yönde
// boşluk ile kenar ucunun ortasına delik konur; sol taraf bunun aynasıdır.
// Böylece ön ve arka levha karşılıklı kapanınca delikler üst üste gelir.
DELIK_MESAFE = (bosluk + kenar) / 2;
function _kesisim(y) = [for (i = [0:len(S_PTS)-1])
    let(a = S_PTS[i], b = S_PTS[(i + 1) % len(S_PTS)])
    if ((a[1] - y) * (b[1] - y) <= 0 && a[1] != b[1])
        let(t = (y - a[1]) / (b[1] - a[1]), d = b - a, n = [d[1], -d[0]] / norm(d))
        [a[0] + t * d[0], n[0] < 0 ? -n : n]];
function _sag(y) = let(k = _kesisim(y), xs = [for (q = k) q[0]]) k[search(max(xs), xs)[0]];
DELIK_SAG = [for (f = delik_yukseklikleri)
    let(y = -S_BOY/2 + f * S_BOY, q = _sag(y)) [q[0], y] + q[1] * DELIK_MESAFE];
DELIKLER = concat(DELIK_SAG, [for (p = DELIK_SAG) [-p[0], p[1]]]);
assert(DELIK_MESAFE - delik_d/2 >= bosluk + 0.6, "delik kalıp boşluğuna çok yakın: kenar'ı büyüt ya da delik_d'yi küçült");
assert(kenar - DELIK_MESAFE - delik_d/2 >= 1.2, "deliğin dışında kalan et çok ince: kenar'ı büyüt");
assert(duvar >= kenar, "kalıp duvarı levha kenarından dar olamaz");

// Kubbe: duvara teğetten başlayıp tepede düzleşen dairesel yay.
// i. basamakta silüet ins(i) kadar içerler, yükseklik kubbe*t.
KN = max(2, round(kubbe / kubbe_adim));
function kubbe_ins(i) = let(t = i / KN) kubbe_icerlek * (1 - sqrt(max(0, 1 - t*t)));
function kubbe_h(i)   = kubbe * i / KN;

// ------------------------------------------------------------------- yüz
GOZ_Y  = -S_BOY/2 + goz_yukseklik * S_BOY;
AGIZ_Y = -S_BOY/2 + agiz_yukseklik * S_BOY;
GOZ_X  = goz_aralik * S_EN;

module elips(o) { scale([o[0]/2, o[1]/2]) circle(r = 1, $fn = 64); }
module goz()  { elips(goz_olcu * K); }
module agiz() { elips(agiz_olcu * K); }

// Yerleşim tek yerden: oyuk ve parça aynı modülden çıkar, ayrışamaz.
module yuz_yerlesim() {
    translate([-GOZ_X, GOZ_Y]) goz();
    translate([ GOZ_X, GOZ_Y]) goz();
    translate([0, AGIZ_Y]) agiz();
}
module yuz_oyuklari() { offset(r = yuz_tolerans) yuz_yerlesim(); }

// ----------------------------------------------------------------- parçalar
module levha(oyuklu = false) {
    linear_extrude(kalinlik)
        difference() {
            offset(r = kenar) S();
            if (oyuklu) yuz_oyuklari();
            for (p = DELIKLER) translate(p) circle(d = delik_d, $fn = 32);
        }
}

module zipka() {
    union() {
        linear_extrude(flans) offset(r = duvar) S();
        linear_extrude(flans + govde) S();
        for (i = [1:KN])
            linear_extrude(flans + govde + kubbe_h(i)) offset(r = -kubbe_ins(i)) S();
    }
}

// Kalıp: boşluk + flanşta levhayı tutan pimler (boyu levha kalınlığından biraz kısa,
// zıpka flanşı üstten levhaya basar, pimlere değmez).
module kalip() {
    H = et + kubbe + govde;
    for (p = DELIKLER) translate([p[0], p[1], H - 0.01])
        cylinder(d = delik_d - kalip_pim_bosluk, h = kalinlik - 0.4 + 0.01, $fn = 32);
    difference() {
        union() {   // dış kabuk + flanş
            translate([0, 0, kubbe]) linear_extrude(H - kubbe) offset(r = bosluk + et) S();
            translate([0, 0, H - taban]) linear_extrude(taban) offset(r = duvar) S();
            for (i = [1:KN])
                translate([0, 0, kubbe - kubbe_h(i)])
                    linear_extrude(H - kubbe + kubbe_h(i))
                        offset(r = et) offset(r = -kubbe_ins(i)) offset(r = bosluk) S();
        }
        union() {   // boşluk: üstten aşağı, tabanı kubbeli
            translate([0, 0, et + kubbe]) linear_extrude(govde + 1) offset(r = bosluk) S();
            for (i = [1:KN])
                translate([0, 0, et + kubbe - kubbe_h(i)])
                    linear_extrude(govde + kubbe_h(i) + 1)
                        offset(r = -kubbe_ins(i)) offset(r = bosluk) S();
        }
    }
}

// Geçme pim: başı ve tutamağı tablada, gövdesi yukarı basılır (destek gerekmez).
// Gövde, uca doğru incelen dişlerden oluşur; diş tepesi delikten `sik` kadar kalındır.
// İki kabuğun deliğinden itilerek geçirilir, tutamaktan çekilerek çıkarılır.
module gecme_pim(sik) {
    bas_d = delik_d + 3.6; bas_h = 1.6;
    L = 2 * kalinlik + 0.8;
    adim = 1.2; n = ceil(L / adim);
    difference() {
        hull() { cylinder(d = bas_d, h = bas_h); translate([bas_d/2 + 4, 0, 0]) cylinder(d = 9, h = bas_h); }
        translate([bas_d/2 + 4, 0, -1]) cylinder(d = 5.5, h = bas_h + 2);
    }
    translate([0, 0, bas_h - 0.01]) {
        cylinder(d = delik_d - 0.5, h = L, $fn = 32);
        for (i = [0:n-2]) translate([0, 0, i * adim])
            cylinder(d1 = delik_d + sik, d2 = delik_d - 0.4, h = adim, $fn = 32);
        translate([0, 0, (n-1) * adim]) cylinder(d1 = delik_d - 0.4, d2 = delik_d - 1.2, h = L - (n-1) * adim, $fn = 32);
    }
}
PIM_EN = delik_d + 3.6 + 13;   // baş + tutamak boyu

// U kelepçe (yalnız asma kapağında): ağzı aşağı basılır, iki kabuğun kenarını sıkıştırır.
module kelepce(agiz) {
    g = agiz; e = kelepce_et; d = kelepce_derinlik; L = kelepce_uzunluk;
    difference() {
        translate([-L/2, -(g + 2*e)/2, 0]) cube([L, g + 2*e, d + e]);
        translate([-L/2 - 1, -g/2, -0.5]) cube([L + 2, g, d + 1]);
        translate([-L/2 - 1, -(g + 1.2)/2, -0.7]) cube([L + 2, g + 1.2, 1.2]);   // giriş pahı
    }
}

module kapak(agiz) {
    ust = kelepce_derinlik + kelepce_et;
    R = halka_dis/2; r = halka_ic/2;
    boyun_h = 2;
    halka_z = ust + boyun_h - 0.5 + R;
    assert(halka_z - r >= ust + boyun_h + 0.8, "asma deliği boyunla çakışıyor");
    assert(halka_ic < halka_dis - 1, "halka iç çapı dış çapından küçük olmalı");
    kelepce(agiz);
    translate([-2, -halka_et/2, ust - 0.7]) cube([4, halka_et, boyun_h + 1.4]);
    translate([0, 0, halka_z]) rotate([90, 0, 0])
        linear_extrude(halka_et, center = true)
            difference() { circle(d = halka_dis); circle(d = halka_ic); }
}

module yuz_parcalari() {
    // her takım: 2 göz + 1 ağız, yan yana
    gw = goz_olcu[0]*K; gh = goz_olcu[1]*K; aw = agiz_olcu[0]*K; ah = agiz_olcu[1]*K;
    sat = max(gh, ah) + ARALIK;
    for (n = [0:yuz_takim-1]) translate([0, n * sat, 0]) linear_extrude(yuz_kalinlik) {
        translate([gw/2, 0]) goz();
        translate([gw*1.5 + ARALIK, 0]) goz();
        translate([2*gw + 2*ARALIK + aw/2, 0]) agiz();
    }
}

// ----------------------------------------------------------- tabla düzenleri
LEV_EN  = S_EN  + 2*kenar;
LEV_BOY = S_BOY + 2*kenar;
KAL_EN  = S_EN  + 2*duvar;
KAL_BOY = S_BOY + 2*duvar;

module sira(adet, adim) { for (i = [0:adet-1]) translate([(i - (adet-1)/2) * adim, 0, 0]) children(); }

module levha_takimi() {
    translate([-(LEV_EN + ARALIK)/2, 0, 0]) levha(yuz);
    translate([ (LEV_EN + ARALIK)/2, 0, 0]) levha(false);
    // levhaların altında: her sıkılık için bir sıra pim, en altta kapaklar
    pim_sira = PIM_EN + ARALIK;              // pimler yan yana, tutamak +x yönünde
    pim_der  = delik_d + 3.6 + ARALIK;
    y0 = -LEV_BOY/2 - ARALIK - pim_der/2;
    for (s = [0:len(pim_sikiliklari)-1], i = [0:len(DELIKLER)-1])
        translate([(i - (len(DELIKLER)-1)/2) * pim_sira - PIM_EN/2 + (delik_d + 3.6)/2,
                   y0 - s * pim_der, 0]) gecme_pim(pim_sikiliklari[s]);
    yk = y0 - len(pim_sikiliklari) * pim_der - ARALIK;
    kl = kelepce_uzunluk + ARALIK;
    for (j = [0:len(kapak_agizlari)-1])
        translate([(j - (len(kapak_agizlari)-1)/2) * kl, yk, 0]) kapak(kapak_agizlari[j]);
    tabla_uyarisi(max(2*LEV_EN + ARALIK, len(DELIKLER) * pim_sira),
                  LEV_BOY + ARALIK + len(pim_sikiliklari) * pim_der + 2*ARALIK + 2*halka_et + 12);
}

module kalip_takimi() {
    translate([-(KAL_EN + ARALIK)/2, 0, 0]) kalip();
    translate([ (KAL_EN + ARALIK)/2, 0, 0]) zipka();
    tabla_uyarisi(2*KAL_EN + ARALIK, KAL_BOY);
}

module tabla_uyarisi(en, derinlik) {
    if (en > TABLA || derinlik > TABLA)
        echo(str("UYARI: düzen ", en, " x ", derinlik,
                 " mm — 256 mm tablaya sığmıyor; parçaları tek tek üretin."));
}

// Montaj önizlemesi: kalıp, üstünde şekillenmiş levha yerine düz levha, en üstte zıpka (ters)
module onizleme() {
    H = et + kubbe + govde;
    color("SteelBlue", 0.9) kalip();
    color("White", 0.8) translate([0, 0, H + 0.2]) levha(yuz);
    color("Orange", 0.9) translate([0, 0, H + kalinlik + 15 + flans + govde + kubbe])
        rotate([180, 0, 0]) zipka();
}

// --------------------------------------------------------------------- çıktı
echo(str("Silüet (yaklaşık) ", S_EN, " x ", S_BOY, " mm | levha ", LEV_EN, " x ", LEV_BOY,
         " | kalıp ", KAL_EN, " x ", KAL_BOY, " x ", et + kubbe + govde, " mm"));

if      (parca == "levha_takimi") levha_takimi();
else if (parca == "kalip_takimi") kalip_takimi();
else if (parca == "yuz_takimi")   yuz_parcalari();
else if (parca == "levha_on")     levha(yuz);
else if (parca == "levha_arka")   levha(false);
else if (parca == "kalip")        kalip();
else if (parca == "zipka")        zipka();
else if (parca == "kapak")        kapak(tek_agiz);
else if (parca == "pim")          gecme_pim(tek_pim_sikilik);
else if (parca == "onizleme")     onizleme();
