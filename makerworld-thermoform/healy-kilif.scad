// =====================================================================
//  Healy kılıfı — thermoform, iki kabuk
//  Kalıp/zıpka/silüet thermoform.scad'den gelir; burada Healy'ye özel:
//    - altta kablo için V açıklığı (levhadan kesilir)
//    - yanlarda kabukları tutan C kıskaçlar (tırnakları kenar deliklerine oturur)
//    - üstte iki kabuğu birleştiren gözlü vida + somun; askı vidanın gözünden geçer
// =====================================================================
include <thermoform.scad>

/* [Healy] */
parca_h = "levha"; // [levha:Levha (2 adet basılır), kalip:Dişi kalıp, zipka:Erkek zıpka, c_kiskac:C kıskaç, vida:Gözlü vida, somun:Somun, kucuk_parcalar:Kıskaçlar + vida + somun, kapali:Kapalı kılıf önizleme]
// Alttaki açıklığın eni (mm)
v_en = 37; // [20:0.5:56]
// Açıklığın silüet tabanından yukarı derinliği (mm)
v_derinlik = 11; // [0:0.5:25]
// C kıskaç ağzı = iki kabuk kenarı (2 × levha kalınlığı) + bu boşluk (mm)
c_agiz_bosluk = 0.2; // [0:0.05:1]
// Vida dış çapı (mm)
vida_d = 8; // [6:0.5:10]
// Vida adımı (mm)
vida_adim = 2.5; // [1.25:0.25:3]
// Vida gözünün dış çapı (mm)
goz_dis = 15; // [8:0.5:20]
// Vida gözünün iç (ip) deliği (mm)
goz_ic = 7; // [3:0.5:10]
// Göz kalınlığı (mm)
goz_et = 4; // [2:0.5:6]
// Somun kalınlığı (mm)
somun_h = 5; // [2:0.5:8]

/* [Hidden] */
parca = "yok";               // thermoform.scad kendi başına bir şey çizmesin
sekil = "kutu";
kutu_en = 58; kutu_boy = 60; kutu_kose = 7;
govde = 9; kubbe = 4; kubbe_icerlek = 5;
delik_yukseklikleri = [0.25, 0.75];

S_ALT = -S_BOY/2;  S_UST = S_BOY/2;
KULAK_Y = S_UST + kenar + 3;          // vida deliğinin merkezi
VIDA_DELIK = vida_d + 0.6;
KULAK_R = VIDA_DELIK/2 + 2.7;
c_agiz = 2*kalinlik + c_agiz_bosluk;
assert(KULAK_Y - VIDA_DELIK/2 > S_UST + bosluk + 2, "vida deliği şekillenen bölgeye çok yakın");

// ------------------------------------------------------------------ levha
module v_acikligi() {
    polygon([[-v_en/2, S_ALT - kenar - 1], [v_en/2, S_ALT - kenar - 1],
             [v_en/2, S_ALT], [0, S_ALT + v_derinlik], [-v_en/2, S_ALT]]);
}
module levha_healy() {
    linear_extrude(kalinlik) difference() {
        union() {
            offset(r = kenar) S();
            hull() { translate([0, KULAK_Y]) circle(r = KULAK_R); translate([0, S_UST]) square([2*KULAK_R, 1], center = true); }
        }
        v_acikligi();
        for (p = DELIKLER) translate(p) circle(d = delik_d, $fn = 32);
        translate([0, KULAK_Y]) circle(d = VIDA_DELIK, $fn = 48);
    }
}

// ---------------------------------------------------------------- C kıskaç
// Profil (XY'de) tablaya yatık basılır, Z boyunca uzar. Ağız iki kabuğun kenarını
// kavrar; çenelerdeki tırnaklar kenar deliğine iki taraftan oturur, kıskaç kaymaz.
C_DERIN = kenar - DELIK_MESAFE + delik_d/2 + 1.5;   // çene boyu: delikten 1,5 mm içeri
C_ET = 1.8; C_BOY = 10;
module c_kiskac() {
    difference() {
        translate([0, -c_agiz/2 - C_ET, 0]) cube([C_DERIN + C_ET, c_agiz + 2*C_ET, C_BOY]);
        translate([C_ET, -c_agiz/2, -1]) cube([C_DERIN + 1, c_agiz, C_BOY + 2]);
        // ağız girişinde pah: kenara kolay takılsın
        translate([C_DERIN + C_ET, 0, -1]) rotate([0, 0, 45]) cube([1.6, 1.6, C_BOY + 2], center = false);
        translate([C_DERIN + C_ET, 0, -1]) rotate([0, 0, -135]) cube([1.6, 1.6, C_BOY + 2], center = false);
    }
    // tırnaklar: deliğin merkezi kenardan (kenar - DELIK_MESAFE) içeride
    tx = C_ET + (kenar - DELIK_MESAFE);
    for (s = [-1, 1]) translate([tx, s * c_agiz/2, C_BOY/2])
        rotate([s * 90, 0, 0]) cylinder(d1 = delik_d - 0.5, d2 = delik_d - 1.4, h = 0.6, $fn = 32);
}

// ------------------------------------------------------------- vida ve somun
// Tek ağızlı kaba diş: eksenden kaçık daire döndürülerek yükseltilir. Baskıda
// sağlam, desteksiz çıkar. Somun aynı profilin boşluklu hâliyle oyulur.
DIS_E = vida_adim * 0.25;
module dis(d, L) linear_extrude(L, twist = -360 * L / vida_adim, slices = ceil(L / vida_adim * 24))
    translate([DIS_E, 0]) circle(d = d - 2*DIS_E, $fn = 48);

VIDA_L = 2*kalinlik + somun_h + 1;  // iki kenar + somun + 1 mm
YAKA_D = vida_d * 1.75;
YAKA_PAH = (YAKA_D - vida_d) / 2;    // 45° pah, desteksiz
module vida() {
    dis(vida_d, VIDA_L);
    // yaka: alttan 45° pahlı, desteksiz basılır
    translate([0, 0, VIDA_L]) cylinder(d1 = vida_d, d2 = YAKA_D, h = YAKA_PAH, $fn = 48);
    translate([0, 0, VIDA_L + YAKA_PAH]) cylinder(d = YAKA_D, h = 1.2, $fn = 48);
    // göz: askı ipi buradan geçer
    translate([0, 0, VIDA_L + YAKA_PAH + 1.2 + goz_dis/2 - 1]) rotate([90, 0, 0])
        linear_extrude(goz_et, center = true) difference() { circle(d = goz_dis, $fn = 64); circle(d = goz_ic, $fn = 48); }
}
module somun() {
    difference() {
        cylinder(d = vida_d * 1.85, h = somun_h, $fn = 6);
        translate([0, 0, -1]) dis(vida_d + 0.6, somun_h + 2);
    }
}

module kucuk_parcalar() {
    for (i = [0:3]) translate([i * (C_DERIN + C_ET + 6), 0, 0]) c_kiskac();
    translate([0, -22, 0]) vida();
    translate([24, -22, 0]) somun();
}

// ------------------------------------------------------- kapalı kılıf önizleme
// Şekillenmiş kabuğun kaba temsili. Birleşme yüzü z=0; iç yüzey = zıpka gövdesi,
// dışa doğru (-z) 1,2 mm et. İkinci kabuk bunun z'ye göre aynası.
module ic_govde(e = 0) {
    linear_extrude(govde + e) offset(r = e) S();
    for (i = [1:KN]) linear_extrude(govde + kubbe_h(i) + e) offset(r = e) offset(r = -kubbe_ins(i)) S();
}
module kabuk() {
    color("White", 0.95) mirror([0, 0, 1]) difference() {
        union() {
            linear_extrude(kalinlik) difference() {
                union() {
                    offset(r = kenar) S();
                    hull() { translate([0, KULAK_Y]) circle(r = KULAK_R); translate([0, S_UST]) square([2*KULAK_R, 1], center = true); }
                }
                for (p = DELIKLER) translate(p) circle(d = delik_d, $fn = 32);
                translate([0, KULAK_Y]) circle(d = VIDA_DELIK, $fn = 48);
            }
            ic_govde(1.2);
        }
        translate([0, 0, -0.01]) ic_govde(0);
        translate([0, 0, -1]) linear_extrude(govde + kubbe + 5) v_acikligi();
    }
}
module kapali() {
    kabuk();
    mirror([0, 0, 1]) kabuk();
    for (p = DELIKLER) let(s = p[0] > 0 ? 1 : -1)
        color("Tomato") translate([p[0] + s * (kenar - DELIK_MESAFE + C_ET), p[1], 0])
            rotate([0, 0, s > 0 ? 180 : 0]) rotate([90, 0, 0]) translate([0, 0, -C_BOY/2]) c_kiskac();
    color("Orange") translate([0, KULAK_Y, kalinlik - VIDA_L]) vida();
    color("Orange") translate([0, KULAK_Y, -kalinlik - somun_h]) somun();
}

if      (parca_h == "levha")          levha_healy();
else if (parca_h == "kalip")          kalip();
else if (parca_h == "zipka")          zipka();
else if (parca_h == "c_kiskac")       c_kiskac();
else if (parca_h == "vida")           vida();
else if (parca_h == "somun")          somun();
else if (parca_h == "kucuk_parcalar") kucuk_parcalar();
else if (parca_h == "kapali")         kapali();
