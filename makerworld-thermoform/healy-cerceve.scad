// =====================================================================
//  Healy kılıfı — ÇERÇEVE YÖNTEMİ (çalışan kalp-80-ref setinin ölçüleriyle)
//
//  Dişi kalıp yok. Parçalar:
//    - Erkek kalıp: 3 mm taban + cihaz şeklinde çıkıntı + iki kılavuz direk.
//    - Oluklu çerçeve: 10 mm, %100 dolu. Altındaki oluğa levhanın kilit
//      kaburgası oturur; çerçeve direklere geçip aşağı inince ısınmış levhayı
//      çıkıntının üstüne gerer, kenarını tabana bastırır.
//    - Levha: 1 mm düz (desen dilimleyicide: %25 honeycomb, alt/üst kabuk 0),
//      kenarda 9 mm pay, en dışta 1,8 × 3,5 mm kilit kaburgası, üstte yarım vida.
//    - Yan kıskaç (kalp setindekiyle aynı ölçü), askılı somun.
//
//  Kullanım koordinatı: z = 0 erkek kalıbın taban üstü = birleşme yüzü.
//  Kabuğun iç yüzü erkek kalıbın yüzeyidir.
// =====================================================================

/* [Parça] */
parca = "kapali_sahne"; // [levha, erkek, cerceve, cerceve_baski, kiskac, somun, kabuk, ic, bant, basma_sahne, kapali_sahne]

/* [Cihaz] */
cihaz_en = 56;
cihaz_boy = 58;
cihaz_h = 18.5;
cihaz_bosluk = 1;
kose = 7;
v_en = 37;
v_derinlik = 11;
egim = 2;        // kabuk yan duvar eğimi (derece)
tavan_r = 2;     // tavan kenar yuvarlaması

/* [Levha — kalp-80-ref] */
kalinlik = 1.0;
levha_kenar = 9.0;        // şeklin dışındaki pay
kaburga_en = 1.8;
kaburga_h = 3.5;          // levhanın üstüne
bant_en = 6.5;            // kenarda dolu (eş merkezli %100) bant
v_basma = 2.0;            // (taban yöntemi) V kenarında çerçevenin bastırdığı şerit
// V yöntemi: "ust" = levha V'de cihazın üst yüzünde biter, çentiğin duvarları açık
//            "taban" = levha çentiğin duvarlarını sarar, kenarı tabanda (ilk deneme)
v_yontem = "ust";
v_ic = 3.0;               // (ust) levhanın V kenarı, çentik çizgisinin bu kadar içinde
v_dudak = 3.0;            // (ust) çerçeve dudağı levhanın üstüne bu kadar taşar

/* [Çerçeve — kalp-80-ref] */
cerceve_h = 10;
acik_pay = 3.4;           // çerçeve iç açıklığı: şekil + bu pay (ölçüldü)
oluk_pay = 0.15;
oluk_derin = 3.8;
cerceve_duvar = 4.0;      // oluğun dışında kalan duvar
tutamak_boy = 19;
tutamak_en = 18;

/* [Erkek kalıp] */
taban = 3;
direk_d = 8;
direk_pay = 0.3;
direk_tasma = 6;          // direk, çıkıntının üstünden bu kadar yükselir

/* [Vida ve somun] */
vida_d = 10;
vida_adim = 2;
vida_boy = 6;
somun_bosluk = 0.6;
halka_d = 10;
halka_delik = 4.5;

/* [Hidden] */
$fn = 48;
IC_EN  = cihaz_en  + 2*cihaz_bosluk;
IC_BOY = cihaz_boy + 2*cihaz_bosluk;
D = cihaz_h/2 + 0.75;
S_UST = IC_BOY/2;  S_ALT = -IC_BOY/2;
N_KAT = 40;
RIB_H = kalinlik + kaburga_h;                     // 4,5
HALKA_DIS = levha_kenar + oluk_pay + cerceve_duvar; // çerçeve halkasının dış hattı (şekilden)
TUT_X = IC_EN/2 + HALKA_DIS;                      // halkanın yan dış kenarı
DIREK_X = TUT_X + tutamak_boy - 9.5;

// ------------------------------------------------------------- silüet
module kutu2d(en, boy, r) offset(r) square([en - 2*r, boy - 2*r], center = true);
module v2d() offset(r = 1.5) offset(delta = -1.5)
    polygon([[-v_en/2, S_ALT - 20], [v_en/2, S_ALT - 20], [v_en/2, S_ALT],
             [0, S_ALT + v_derinlik], [-v_en/2, S_ALT]]);
module IC() difference() { kutu2d(IC_EN, IC_BOY, kose); offset(r = -cihaz_bosluk) v2d(); }
function ins(z) = z * tan(egim) +
    (z > D - tavan_r ? tavan_r - sqrt(max(0, tavan_r*tavan_r - pow(z - (D - tavan_r), 2))) : 0);
module ic_hacim(e = 0) for (i = [0 : N_KAT - 1]) {
    z0 = D * i / N_KAT;  z1 = D * (i + 1) / N_KAT;
    translate([0, 0, i == 0 ? -0.01 : z0]) linear_extrude(z1 - z0 + (i == 0 ? 0.01 : 0) + 0.001)
        offset(r = e - ins(z1)) IC();
}

// ---------------------------------------------------------------- vida
DIS_H = vida_adim * 0.35;
LEAD = 2 * vida_adim;
P_UST = S_UST + levha_kenar;                // levhanın üst kenarı
VIDA_Y0 = P_UST - kaburga_en;               // vida kaburganın içinden başlar
VIDA_Y1 = VIDA_Y0 + vida_boy;
BOYUN_EN = vida_d - 2*DIS_H;
module dis2(d, L) linear_extrude(L, twist = -360 * L / LEAD, slices = ceil(L / LEAD * 36))
    scale([1, (d - 2*DIS_H) / d]) circle(d = d, $fn = 64);
module tam_vida() translate([0, VIDA_Y0, 0]) rotate([-90, 0, 0]) dis2(vida_d, vida_boy);
module yarim_vida() intersection() {
    tam_vida();
    translate([-vida_d, VIDA_Y0 - 1, 0]) cube([2*vida_d, vida_boy + 2, vida_d]);
}

// --------------------------------------------------------------- levha
module P0() offset(r = levha_kenar) IC();                // kesilmemiş dış hat
// V açıklığı: levha V'de önceden açık basılır. Kesik kenar, kalıbın V
// duvarından açık payı + v_basma kadar uzakta durur; çerçeve V'nin içine
// uzanan kısmıyla bu v_basma şeridini tabana bastırır.
module N() offset(r = -cihaz_bosluk) v2d();             // cihazın çentiği (kalıpta)
module VKES() if (v_yontem == "ust") offset(r = v_ic) N();
              else offset(r = -(acik_pay + v_basma)) N();
module P() difference() { P0(); VKES(); }               // levhanın dış hattı
// Kaburga dış hat boyunca; V kesiğinde yok (orayı çerçeve düz bastırır)
module kaburga_2d() difference() { P0(); offset(r = -kaburga_en) P0(); offset(r = kaburga_en) VKES(); }
module levha() {
    linear_extrude(kalinlik) union() {
        P();
        translate([-BOYUN_EN/2, S_UST]) square([BOYUN_EN, VIDA_Y1 - S_UST]);
    }
    linear_extrude(RIB_H) kaburga_2d();
    yarim_vida();
}
// Dilimleyici için: kenar bandı (eş merkezli %100 dolgu değiştiricisi)
module bant() linear_extrude(kalinlik) difference() { P(); offset(r = -bant_en) P(); }

// ------------------------------------------------------------ çerçeve
module halka_2d() union() {
    offset(r = HALKA_DIS) IC();
    // tutamaklar (direk delikleri bunlarda)
    for (s = [-1, 1]) translate([s * (TUT_X + tutamak_boy/2 - 2), 0])
        offset(r = 3) offset(delta = -3) square([tutamak_boy + 4, tutamak_en], center = true);
    // vida yatağını taşıyan dil
    translate([-(vida_d/2 + 3.3), 0]) square([vida_d + 6.6, VIDA_Y1 + 3.5]);
}
module cerceve_2d() difference() { halka_2d(); offset(r = acik_pay) IC(); }
// Kullanım konumu: alt yüzü levhanın üstünde (z = kalinlik)
// (ust) V dudağı: çentiği doldurur, kalıbın üstüne taşıp levhanın V kenarını
// kalıbın üst yüzüne bastırır. Alt yüzü kabuğun dış yüzünü izler (dik iner, takılmaz).
DUDAK_UST = D + kalinlik + 2;
// Çerçevenin üstü her yerde düz: ust yönteminde dudakla aynı yükseklik (12 mm),
// böylece ters çevrilip düz yüzü tablada desteksiz basılır.
CERCEVE_UST = v_yontem == "ust" ? max(DUDAK_UST, kalinlik + cerceve_h) : kalinlik + cerceve_h;
module v_dudak_blok() difference() {
    translate([0, 0, kalinlik]) linear_extrude(DUDAK_UST - kalinlik)
        intersection() { offset(r = v_ic + v_dudak) N(); halka_2d(); }
    ic_hacim(0.3);
    translate([0, 0, D]) linear_extrude(0.3) offset(r = 0.3 - ins(D)) IC();
    dis_hacim(0);
}
module cerceve() difference() {
    union() {
        translate([0, 0, kalinlik]) linear_extrude(CERCEVE_UST - kalinlik) cerceve_2d();
        if (v_yontem == "ust") v_dudak_blok();
    }
    // kilit kaburgası oluğu
    translate([0, 0, kalinlik - 0.01]) linear_extrude(oluk_derin + 0.01)
        offset(delta = oluk_pay) kaburga_2d();
    // direk delikleri
    for (s = [-1, 1]) translate([s * DIREK_X, 0, -1]) cylinder(d = direk_d + 2*direk_pay, h = cerceve_h + 5);
    // yarım vida yatağı (vidayı tabana bastırır)
    translate([0, VIDA_Y0 - 0.2, 0]) rotate([-90, 0, 0]) cylinder(d = vida_d + 0.6, h = vida_boy + 0.7, $fn = 64);
}
// Baskı konumu: oluk yukarı bakar
module cerceve_baski() translate([0, 0, CERCEVE_UST]) mirror([0, 0, 1]) cerceve();

// ---------------------------------------------------------- erkek kalıp
module erkek() {
    translate([0, 0, -taban]) linear_extrude(taban) offset(r = 1) halka_2d();
    ic_hacim(0);
    for (s = [-1, 1]) translate([s * DIREK_X, 0, -taban]) cylinder(d = direk_d, h = taban + D + direk_tasma + 1);
}

// --------------------------------------------------------------- kıskaç
// kalp-80-ref yan kıskacı: U, ağız 2 × (levha + kaburga), çene 3 mm, uçta 0,2 tırnak
K_AGIZ = 2 * RIB_H;
K_ET = 1.6;  K_CENE = 3.0;  K_GEN = 5;
module kiskac_2d() {
    difference() {
        translate([0, -K_AGIZ/2 - K_ET]) square([K_ET + K_CENE, K_AGIZ + 2*K_ET]);
        translate([K_ET, -K_AGIZ/2]) square([K_CENE + 1, K_AGIZ]);
    }
    for (s = [1, -1]) scale([1, s]) translate([K_ET + 1.6, K_AGIZ/2])
        polygon([[0, 0.01], [0.24, -0.2], [0.72, -0.2], [0.96, 0.01]]);
}
module kiskac() linear_extrude(K_GEN) kiskac_2d();

// ----------------------------------------------------------------- somun
SOMUN_H = vida_boy - 1;
SOMUN_D = vida_d + 5;
module somun() {
    difference() {
        cylinder(d = SOMUN_D, h = SOMUN_H, $fn = 8);
        translate([0, 0, -1]) dis2(vida_d + somun_bosluk, SOMUN_H + 2);
        translate([0, 0, -0.01]) cylinder(d1 = vida_d + 1.2, d2 = vida_d - 0.4, h = 0.8);
    }
    translate([0, 0, SOMUN_H - 0.01]) cylinder(d = SOMUN_D, h = 1.2, $fn = 8);
    translate([0, 0, SOMUN_H + 1.2 + halka_d/2 - 1]) rotate([0, 90, 0])
        linear_extrude(3, center = true) difference() { circle(d = halka_d); circle(d = halka_delik); }
}

// ------------------------------------------------- şekillenmiş kabuk
// Kabuğun dış yüzü: iç yüzden levha kalınlığı kadar dışarıda, tavanı da dahil
module dis_hacim(e = 0) for (i = [0 : N_KAT - 1]) {
    Dd = D + kalinlik + e;
    z0 = Dd * i / N_KAT;  z1 = Dd * (i + 1) / N_KAT;
    translate([0, 0, z0]) linear_extrude(z1 - z0 + 0.001)
        offset(r = kalinlik + e - ins(min(D, z1))) IC();
}
module kabuk() {
    intersection() { translate([-200, -200, 0]) cube([400, 400, 50]); difference() {
        union() {
            dis_hacim();
            linear_extrude(kalinlik) P();
            linear_extrude(RIB_H) kaburga_2d();
        }
        ic_hacim(0);
        // (ust) V'de levha yok: çentiğin duvarları ve kenarın 3 mm'si açık
        if (v_yontem == "ust") translate([0, 0, -1]) linear_extrude(D + 5) VKES();
    } }
    yarim_vida();
}

// --------------------------------------------------------------- sahneler
module basma_sahne() {
    color("SlateGray") erkek();
    color("Orange") kabuk();
    color("MediumPurple", 0.85) cerceve();
}
module kapali_sahne() {
    color("Orange") kabuk();
    color("SandyBrown") rotate([0, 180, 0]) kabuk();
    for (s = [-1, 1]) color("Tomato")
        translate([s * (IC_EN/2 + levha_kenar + K_ET), 0, 0]) rotate([0, 0, s > 0 ? 180 : 0])
            rotate([90, 0, 0]) translate([0, 0, -K_GEN/2]) kiskac();
    color("Gold") translate([0, VIDA_Y0 + 0.5, 0]) rotate([-90, 0, 0]) somun();
}

if      (parca == "levha")         levha();
else if (parca == "erkek")         erkek();
else if (parca == "cerceve")       cerceve();
else if (parca == "cerceve_baski") cerceve_baski();
else if (parca == "kiskac")        kiskac();
else if (parca == "somun")         somun();
else if (parca == "kabuk")         kabuk();
else if (parca == "ic")            ic_hacim(0);
else if (parca == "bant")          bant();
// 3MF için levhanın ayrı ayarlı parçaları
else if (parca == "levha_duz")     linear_extrude(kalinlik) union() { P(); translate([-BOYUN_EN/2, S_UST]) square([BOYUN_EN, VIDA_Y1 - S_UST]); }
else if (parca == "kaburga")       translate([0, 0, kalinlik - 0.01]) linear_extrude(RIB_H - kalinlik + 0.01) kaburga_2d();
else if (parca == "vida")          yarim_vida();
else if (parca == "direk_destek")  for (s = [-1, 1]) translate([s * DIREK_X, 0, -taban]) cylinder(d = direk_d + 1, h = taban + D + direk_tasma + 1);
else if (parca == "basma_sahne")   basma_sahne();
else if (parca == "kapali_sahne")  kapali_sahne();
