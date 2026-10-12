// =====================================================================
//  Healy kılıfı — thermoform, iki kabuk
//  Kalıp/zıpka/silüet thermoform.scad'den gelir; burada Healy'ye özel:
//    - altta kablo için V açıklığı (levhadan kesilir)
//    - yanlarda kabukları tutan C kıskaçlar (tırnakları kenar deliklerine oturur)
//    - üstte her levhada YARIM VİDA: kabuklar kapanınca iki yarım tam vida olur,
//      üstüne askı halkalı somun takılır; somun iki yarıyı birbirine bağlar.
//
//  Levha, BİRLEŞME YÜZÜ tablaya bakacak şekilde basılır (yarım vidanın düz yüzü
//  tablada, yuvarlak dişli tarafı yukarıda — desteksiz). Kalıba konurken bu yüz
//  yukarı, zıpkaya bakar. İki levha aynı dosyadır; biri ters çevrilip kapanır.
// =====================================================================
include <thermoform.scad>

/* [Healy] */
parca_h = "levha"; // [levha:Levha (2 adet basılır), kalip:Dişi kalıp, zipka:Erkek zıpka, c_kiskac:C kıskaç, somun:Askılı somun, kucuk_parcalar:2 kıskaç + somun, kapali:Kapalı kılıf önizleme]
// Levha kalınlığı (mm)
kalinlik = 1.6; // [1:0.2:3]
// Alttaki açıklığın eni (mm)
v_en = 37; // [20:0.5:56]
// Açıklığın silüet tabanından yukarı derinliği (mm)
v_derinlik = 11; // [0:0.5:25]
// Levha deseni (modelde açılan, boydan boya delikler)
desen = "yok"; // [altigen:Bal peteği, baklava:Baklava, kare:Kare ızgara, daire:Yuvarlak delik, ucgen:Üçgen, yok:Desensiz]
// Delik büyüklüğü (mm)
petek_d = 5; // [2:0.5:10]
// Delikler arası çubuk kalınlığı (mm)
petek_cubuk = 1.2; // [0.8:0.1:3]
// Desensiz bırakılan kenar şeridi (silüetin içinde, mm)
petek_kenar = 2; // [1:0.5:6]
// C kıskaç ağzı = iki kabuk kenarı (2 × levha kalınlığı) + bu boşluk (mm)
c_agiz_bosluk = 0.2; // [0:0.05:1]
// Vida dış çapı (mm) — iki yarımın birleşmiş hâli
vida_d = 7; // [5:0.5:10]
// Diş adımı (mm) — iki ağızlı diş, ilerleme = 2 × adım
vida_adim = 2; // [1.5:0.25:3]
// Vida boyu (mm)
vida_boy = 7; // [4:0.5:12]
// Somun boşluğu (mm, çapta)
somun_bosluk = 0.6; // [0.2:0.1:1.2]
// Askı halkası dış çapı (mm)
halka_d = 10; // [7:0.5:16]
// Askı deliği (mm)
halka_delik = 4.5; // [2.5:0.5:8]

/* [Hidden] */
parca = "yok";               // thermoform.scad kendi başına bir şey çizmesin
sekil = "kutu";
kutu_en = 58; kutu_boy = 60; kutu_kose = 7;
govde = 9.4; kubbe = 0.6; kubbe_icerlek = 3;   // iç boşluk: kenarda 2×9,4 = 18,8 · ortada 2×10 = 20 mm
delik_yukseklikleri = [];             // kenar deliği/pim yok: levha kalıba dış hatları çakıştırılarak oturur
// Fincan kalıp yapısı (referans fotoğraftaki gibi):
//   kalıp boşluğu = silüet + levha kalınlığı, duvar 3 mm, üst kenarı dar
//   levhanın dış hattı = kalıbın dış hattı (kenar = bosluk + et)
//   zıpka taban plakası kalıptan 1 mm geniş, levha kenarını kalıp kenarına sıkıştırır
// NOT: OpenSCAD'da yeniden atanan değişken ilk atandığı yerde hesaplanır; bu
// yüzden aşağıdakiler sabit yazıldı. Levha kalınlığı değişirse bosluk = kalinlik,
// kenar = bosluk + et, duvar = kenar + 1 olacak şekilde elle güncelle.
bosluk = 1.6;                          // yan boşluk = levha kalınlığı (taban boşluğu zaten öyle)
et = 3;
kenar = 4.6;                           // = bosluk + et → levhanın dış hattı = kalıbın dış hattı
duvar = 5.6;                           // = kenar + 1 → zıpka taban plakası
flans = 3;                             // zıpka taban plakası kalınlığı
delik_d = 0.2;                         // (thermoform.scad denetimleri için; delik açılmıyor)

S_ALT = -S_BOY/2;  S_UST = S_BOY/2;
assert(abs(bosluk - kalinlik) < 0.01 && abs(kenar - (bosluk + et)) < 0.01 && abs(duvar - (kenar + 1)) < 0.01,
       "bosluk/kenar/duvar levha kalınlığına göre güncellenmemiş");
c_agiz = 2*kalinlik + c_agiz_bosluk;
// Yarım vida kalıp flanşının dışından başlar: levha kalıba yatarken vidanın
// yuvarlak tarafı aşağı sarkar, flanşa değmemeli.
VIDA_Y0 = S_UST + duvar + 1;           // zıpka taban plakasının dışında başlar
DIS_H = vida_adim * 0.35;               // diş derinliği
LEAD = 2 * vida_adim;                   // iki ağızlı: ilerleme

// ------------------------------------------------------------ iki ağızlı diş
// Elips kesit döndürülerek yükseltilir. Elips 180°'de kendisiyle çakıştığı için
// diş iki ağızlıdır: aynı levha ters çevrildiğinde yarımlar dişte kaymadan birleşir.
module dis2(d, L) linear_extrude(L, twist = -360 * L / LEAD, slices = ceil(L / LEAD * 36))
    scale([1, (d - 2*DIS_H) / d]) circle(d = d, $fn = 64);

// Tam vida, levha koordinatında: ekseni Y yönünde, z = 0 (birleşme yüzü) üzerinde.
module tam_vida() translate([0, VIDA_Y0, 0]) rotate([-90, 0, 0]) dis2(vida_d, vida_boy);

module yarim_vida() intersection() {
    tam_vida();
    translate([-vida_d, VIDA_Y0 - 1, 0]) cube([2*vida_d, vida_boy + 2, vida_d]);
}

// ------------------------------------------------------------------ levha
module v_acikligi() {
    polygon([[-v_en/2, S_ALT - kenar - 1], [v_en/2, S_ALT - kenar - 1],
             [v_en/2, S_ALT], [0, S_ALT + v_derinlik], [-v_en/2, S_ALT]]);
}
BOYUN_EN = vida_d - 2*DIS_H;            // vidayı kenara bağlayan düz boyun
// Kulaklar: levhanın iki yanında, ortada. Hem sıcak levhayı tutma yeri hem de
// kıskaç yuvasının yeri. Kalıbın dışında kalır, şekil almaz, düz durur.
KULAK_BOY = 8;      // dışa uzanım
KULAK_EN  = 9;      // kenar boyunca
KISKAC_YER = [for (s = [-1, 1]) [s * (S_EN/2 + kenar + KULAK_BOY/2), 0]];
module kulaklar_2d() for (s = [-1, 1])
    translate([s * (S_EN/2 + kenar + KULAK_BOY/2), 0])
        // kenara 2 mm gömülür (sağlam bağlansın), dış ucu tam KULAK_BOY'da biter
        translate([s > 0 ? -KULAK_BOY/2 - 2 : -KULAK_BOY/2, -KULAK_EN/2])
            offset(r = 1.5) offset(delta = -1.5) square([KULAK_BOY + 2, KULAK_EN]);
module levha_2d() difference() {
    union() {
        offset(r = kenar) S();
        kulaklar_2d();
        translate([-BOYUN_EN/2, S_UST]) square([BOYUN_EN, VIDA_Y0 - S_UST + 0.5]);
    }
    for (p = KISKAC_YER) translate(p) yuva_2d(0);
    // V önceden kesilir; kenar kalıptaki sırtın hemen dışına oturur, ona dayanır
    offset(r = SIRT/2 + 0.15) v_acikligi();
    if (desen != "yok") desen_delikleri();
}
// Kıskaç yuvası: kenarda dörtgen boşluk (uzun kenarı levha kenarına paralel).
// Aynı yuva kalıpta pimi, zıpkada pim deliğini belirler.
YUVA_U = 4.0;   // kenar boyunca
YUVA_G = 2.0;   // kenara dik
module yuva_2d(e = 0) square([YUVA_G + 2*e, YUVA_U + 2*e], center = true);
// Desen: modelde açılan, levhayı boydan boya geçen delikler. Silüetin kenar
// şeridi ve V'nin çevresi dolu kalır. Her desende delik ≈ petek_d, çubuk = petek_cubuk.
module desen_alani() difference() {
    offset(r = -petek_kenar) S();
    offset(r = SIRT/2 + 0.15 + petek_kenar) v_acikligi();
}
module desen_delikleri() intersection() {
    desen_alani();
    a = petek_d; c = petek_cubuk; N = ceil(max(S_EN, S_BOY) / (a + c)) + 2;
    if (desen == "altigen" || desen == "daire") {
        adim = a + c; sat = adim * sqrt(3) / 2;
        for (j = [-N : N], i = [-N : N]) translate([i * adim + (j % 2 == 0 ? 0 : adim / 2), j * sat])
            if (desen == "altigen") rotate(30) circle(d = a / cos(30), $fn = 6);
            else circle(d = a, $fn = 32);
    } else if (desen == "kare") {
        adim = a + c;
        for (j = [-N : N], i = [-N : N]) translate([i * adim, j * adim]) square(a, center = true);
    } else if (desen == "baklava") {
        // 45° dönmüş kareler; çubuklar köşegen yönünde — en iyi esneyen ızgara
        adim = (a + c) * sqrt(2);
        for (j = [-2*N : 2*N], i = [-N : N]) translate([i * adim + (j % 2 == 0 ? 0 : adim / 2), j * adim / 2])
            rotate(45) square(a, center = true);
    } else if (desen == "ucgen") {
        // eşkenar üçgenler, yukarı/aşağı sırayla; aralar c kalınlığında çubuk
        t = (a + c) * sqrt(3);  R = t / sqrt(3);  dy = 1.5 * R;
        for (j = [-N : N], i = [-2*N : 2*N]) let(yuk = (i + j) % 2 == 0)
            translate([i * t / 2, j * dy + (yuk ? R/2 : R) - 0.75 * R])
                offset(delta = -c / 2) rotate(yuk ? 90 : -90) circle(r = R, $fn = 3);
    }
}

module levha_healy() {
    linear_extrude(kalinlik) levha_2d();
    yarim_vida();
}

// ---------------------------------------------------------------- C kıskaç
// İnce bir C: arkası düz, iki çenenin ucunda içe dönük tırnak. Tırnaklar kenardaki
// dörtgen yuvaya iki yüzden oturur. Profil (XY) tablaya yatık basılır, Z boyunca
// C_BOY kadar uzar — desteksiz. Girişte tırnak pahlı, arkası dik (kilitler).
C_ET   = 1.2;                               // sırt ve çene kalınlığı
C_BOY  = YUVA_U - 0.6;                      // kıskaç genişliği (yuvaya girer)
TIRNAK = 0.6;                               // tırnağın içe çıkıntısı
YUVA_M = KULAK_BOY / 2;                     // yuva merkezinin kulak ucundan uzaklığı
C_DERIN = YUVA_M + (YUVA_G - 0.4) / 2;      // çene boyu: tırnağın dış kenarına kadar
module c_kiskac_2d() {
    m = c_agiz / 2;  tw = YUVA_G - 0.4;  x0 = C_ET + YUVA_M - tw/2;
    difference() {
        translate([0, -m - C_ET]) square([C_ET + C_DERIN, c_agiz + 2*C_ET]);
        translate([C_ET, -m]) square([C_DERIN + 1, c_agiz]);
    }
    for (s = [1, -1]) scale([1, s])
        polygon([[x0, m], [x0, m - TIRNAK], [x0 + tw * 0.4, m - TIRNAK], [x0 + tw, m]]);
}
module c_kiskac() linear_extrude(C_BOY) c_kiskac_2d();

// ------------------------------------------------------------ askılı somun
// Tablaya düz basılır; halka üstte dik durur, deliği yatay (ip sağdan sola geçer).
SOMUN_H = vida_boy - 1;
SOMUN_D = vida_d + 5;
module somun() {
    difference() {
        cylinder(d = SOMUN_D, h = SOMUN_H, $fn = 8);
        translate([0, 0, -1]) dis2(vida_d + somun_bosluk, SOMUN_H + 2);
        translate([0, 0, -0.01]) cylinder(d1 = vida_d + 1.2, d2 = vida_d - 0.4, h = 0.8, $fn = 48);   // giriş pahı
    }
    // somunun tavanı: halka buna oturur
    translate([0, 0, SOMUN_H - 0.01]) cylinder(d = SOMUN_D, h = 1.2, $fn = 8);
    translate([0, 0, SOMUN_H + 1.2 + halka_d/2 - 1]) rotate([0, 90, 0])
        linear_extrude(3, center = true) difference() { circle(d = halka_d, $fn = 48); circle(d = halka_delik, $fn = 32); }
}

module kucuk_parcalar() {
    for (i = [0:1]) translate([i * (C_DERIN + C_ET + 6), 0, 0]) c_kiskac();
    translate([0, -20, 0]) somun();
}

// ------------------------------------------------------- kapalı kılıf önizleme
// Şekillenmiş kabuğun kaba temsili. Birleşme yüzü z = 0; kabuk +z'ye kubbelenir.
// İkinci kabuk aynı levhanın Y ekseni etrafında 180° çevrilmişidir.
module ic_govde(e = 0) {
    linear_extrude(govde + e) offset(r = e) S();
    for (i = [1:KN]) linear_extrude(govde + kubbe_h(i) + e) offset(r = e) offset(r = -kubbe_ins(i)) S();
}
module kabuk() {
    color("White", 0.95) difference() {
        union() { linear_extrude(kalinlik) levha_2d(); ic_govde(1.2); }
        translate([0, 0, -0.01]) ic_govde(0);
        translate([0, 0, -1]) linear_extrude(govde + kubbe + 5) v_acikligi();
    }
    color("White", 0.95) yarim_vida();
}
module kapali() {
    kabuk();
    rotate([0, 180, 0]) kabuk();
    for (p = KISKAC_YER) let(s = p[0] > 0 ? 1 : -1)
        color("Tomato") translate([p[0] + s * (YUVA_M + C_ET), p[1], 0])
            rotate([0, 0, s > 0 ? 180 : 0]) rotate([90, 0, 0]) translate([0, 0, -C_BOY/2]) c_kiskac();
    color("Orange") translate([0, VIDA_Y0 + 0.5, 0]) rotate([-90, 0, 0]) somun();
}

// ------------------------------------------------- V kesim çizgisi (kalıpta)
// Kalıp boşluğunun yüzeyinde V çizgisini izleyen ince bir sırt DAYANAKTIR:
// levhada önceden kesilmiş V'nin kenarı bu sırtın dışına oturur. Zıpka sonuna
// kadar inip yüzü kalıp tabanına sıkıştırınca kenar sırta dayanır, V'nin içine
// kayamaz; duvardaki dikey kenarlar da aynı sırta dayanır. Sonradan kesim yok.
SIRT = 0.8;                                    // sırt yüksekliği = kalınlığı
module bosluk_govde(e = 0) {                   // kalıp boşluğu, e kadar içeri alınmış
    H = et + kubbe + govde;
    translate([0, 0, et + kubbe + e]) linear_extrude(govde + 1) offset(r = -e) offset(r = bosluk) S();
    for (i = [1:KN])
        translate([0, 0, et + kubbe - kubbe_h(i) + e])
            linear_extrude(govde + kubbe_h(i) + 1) offset(r = -e) offset(r = -kubbe_ins(i)) offset(r = bosluk) S();
}
V_YOL = [[-v_en/2, S_ALT - bosluk - 3], [-v_en/2, S_ALT], [0, S_ALT + v_derinlik],
         [v_en/2, S_ALT], [v_en/2, S_ALT - bosluk - 3]];
module v_cizgi_2d() for (i = [0:len(V_YOL) - 2])
    hull() { translate(V_YOL[i]) circle(d = SIRT, $fn = 16); translate(V_YOL[i+1]) circle(d = SIRT, $fn = 16); }
module v_sirt() intersection() {
    translate([0, 0, -1]) linear_extrude(et + kubbe + govde + 1) v_cizgi_2d();   // flanş üstünü aşmaz
    difference() { bosluk_govde(0); bosluk_govde(SIRT); }
}
// Kalıp: fincan. Dış hat = levhanın dış hattı, üst kenar düz ve et kadar dar.
module kalip_healy() {
    H = et + kubbe + govde;
    difference() {
        linear_extrude(H) offset(r = bosluk + et) S();
        bosluk_govde(0);
    }
    v_sirt();
}

// Zıpka: taban plakası (kalıptan 1 mm geniş) + gövde. Plaka levha kenarını
// kalıbın üst kenarına sıkıştırır.
module zipka_healy() zipka();

if      (parca_h == "levha")          levha_healy();
else if (parca_h == "kalip")          kalip_healy();
else if (parca_h == "zipka")          zipka_healy();
else if (parca_h == "c_kiskac")       c_kiskac();
else if (parca_h == "somun")          somun();
else if (parca_h == "kucuk_parcalar") kucuk_parcalar();
else if (parca_h == "kapali")         kapali();
else if (parca_h == "tam_vida")       tam_vida();   // yalnız denetim için
