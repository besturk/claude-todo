// =====================================================================
//  Healy kılıfı — Formify yapısıyla (useless.works/thermoform)
//
//  Yapı:
//    - Levha ince (0,6 mm) ve modellenmiş altıgen kafesli; çevresinde dar,
//      yükseltilmiş bir çerçeve (rim) var.
//    - Dişi kalıpta levhanın birebir oturduğu bir CEP ve çerçevenin girdiği bir
//      OLUK var. Çerçeve oluğa girince levha hiçbir yöne kayamaz.
//    - Kalıplar şekillenmiş kabuktan türetilir: dişi = kabuğun dış yüzü + 0,1,
//      erkek = kabuğun iç yüzü − 0,1. Aradaki boşluk tam levha kalınlığıdır.
//    - V, levhanın DIŞ HATTININ parçasıdır: çerçeve V'nin kenarlarını da dolaşır,
//      oluk V'yi kalıpta sabitler. Sonradan kesim yok.
//    - Üstte her levhada yarım vida; iki yarım birleşip tam vida olur, askı
//      halkalı somun takılır. Yanlarda birer küçük U kıskaç iki çerçeveyi kavrar.
//
//  Kabuk koordinatı: z = 0 birleşme yüzü (iki kabuğun değdiği düz yüz),
//  kabuk +z yönüne kabarır. Levha z = 0 yüzü tablada basılır; çerçeve ve
//  yarım vida yukarıda kalır (desteksiz).
// =====================================================================

/* [Parça] */
parca = "levha"; // [levha:Levha (2 adet basılır), disi:Dişi kalıp, erkek:Erkek kalıp, kiskac:U kıskaç, somun:Askılı somun, kapali:Kapalı kılıf önizleme]

/* [Cihaz] */
// Cihazın eni (mm)
cihaz_en = 56;
// Cihazın boyu (mm)
cihaz_boy = 58;
// Cihaz kalınlığı (iki kabuğun içine girecek, mm)
cihaz_h = 18.5;
// Cihaz çevresinde boşluk (her yanda, mm)
cihaz_bosluk = 1;
// Köşe yarıçapı (iç boşluk, mm)
kose = 7;
// Cihazın altındaki V çentiğinin eni (mm) — kılıf bu çentiği izler, V açık kalır
v_en = 37;
// V çentiğinin alt kenardan yukarı derinliği (mm)
v_derinlik = 11;

/* [Levha] */
// Levha kalınlığı (mm)
kalinlik = 0.6; // [0.4:0.1:1.6]
// Çerçeve genişliği (mm)
rim_en = 1.2;
// Çerçeve yüksekliği, levha dahil (mm)
rim_h = 2;
// Kabuk ile çerçeve arasındaki düz şerit (mm)
duz_serit = 0.6;
// Kafes adımı (mm)
kafes_adim = 4;
// Kafes çubuğu (mm)
kafes_cubuk = 0.8;
// Kafessiz bırakılan kenar şeridi (mm)
kafes_kenar = 1.5;

/* [Kalıp] */
// Kalıp boşluğu (levhanın iki yüzüne toplam, mm)
kalip_bosluk = 0.2;
// Levha cebinin boşluğu (mm)
cep_bosluk = 0.2;
// Dış duvar (mm)
kalip_duvar = 2.5;
// Taban kalınlığı (mm)
kalip_taban = 2;
// Kabuk yan duvar eğimi (derece)
egim = 2;
// Kabuk tavan kenar yuvarlaması (mm)
tavan_r = 2;

/* [Vida ve somun] */
vida_d = 10;
vida_adim = 2;
vida_boy = 6;
somun_bosluk = 0.6;
halka_d = 10;
halka_delik = 4.5;

/* [Kıskaç] */
// Kıskaç ağzı boşluğu (mm)
kiskac_bosluk = 0.2;
// Kıskaç genişliği (mm)
kiskac_en = 6;

/* [Hidden] */
$fn = 48;
IC_EN  = cihaz_en  + 2*cihaz_bosluk;          // 58
IC_BOY = cihaz_boy + 2*cihaz_bosluk;          // 60
D = cihaz_h/2 + 0.75;                          // kabuk iç derinliği (10): eğim ve yuvarlama cihaza değmesin
DIS_OFS = kalinlik + duz_serit + rim_en;       // iç boşluktan levha dış hattına
C = kalip_bosluk/2;
S_UST = IC_BOY/2;  S_ALT = -IC_BOY/2;
N_KAT = 40;

// ------------------------------------------------------------- silüetler
module kutu2d(en, boy, r) offset(r) square([en - 2*r, boy - 2*r], center = true);
module v2d() offset(r = 1.5) offset(delta = -1.5)
    polygon([[-v_en/2, S_ALT - 20], [v_en/2, S_ALT - 20], [v_en/2, S_ALT],
             [0, S_ALT + v_derinlik], [-v_en/2, S_ALT]]);
// İç boşluğun birleşme yüzündeki hattı (V çentikli)
module IC() difference() { kutu2d(IC_EN, IC_BOY, kose); offset(r = -cihaz_bosluk) v2d(); }
// Levhanın dış hattı (çerçevenin dış kenarı) — V'yi de dolaşır
module DIS() offset(r = DIS_OFS) IC();

// İçe çekilme: yan duvar eğimi + tavan kenarı yuvarlaması
function ins(z) = z * tan(egim) +
    (z > D - tavan_r ? tavan_r - sqrt(max(0, tavan_r*tavan_r - pow(z - (D - tavan_r), 2))) : 0);

// Kabuğun iç hacmi (cihazın oturduğu yer), e kadar büyütülmüş
module ic_hacim(e = 0) for (i = [0 : N_KAT - 1]) {
    z0 = D * i / N_KAT;  z1 = D * (i + 1) / N_KAT;
    translate([0, 0, i == 0 ? -0.01 : z0]) linear_extrude(z1 - z0 + (i == 0 ? 0.01 : 0) + 0.001)
        offset(r = e - ins(z1)) IC();
}

// --------------------------------------------------------------- vida
DIS_H = vida_adim * 0.35;
LEAD = 2 * vida_adim;
// Vida çerçevenin içinden başlar: arada ince, bükülebilen boyun kalmaz
VIDA_Y0 = S_UST + DIS_OFS - rim_en;
VIDA_Y1 = VIDA_Y0 + vida_boy;            // vidanın ucu
module dis2(d, L) linear_extrude(L, twist = -360 * L / LEAD, slices = ceil(L / LEAD * 36))
    scale([1, (d - 2*DIS_H) / d]) circle(d = d, $fn = 64);
module tam_vida() translate([0, VIDA_Y0, 0]) rotate([-90, 0, 0]) dis2(vida_d, vida_boy);
module yarim_vida() intersection() {
    tam_vida();
    translate([-vida_d, VIDA_Y0 - 1, 0]) cube([2*vida_d, vida_boy + 2, vida_d]);
}
BOYUN_EN = vida_d - 2*DIS_H;
module boyun_2d() translate([-BOYUN_EN/2, S_UST]) square([BOYUN_EN, VIDA_Y1 - S_UST]);
// Kalıpların vidayı baştan sona taşıyan dili (dış hatta eklenir)
DIL_EN = vida_d + 0.6 + 2*kalip_duvar;
module dil_2d() translate([-DIL_EN/2, S_UST]) square([DIL_EN, VIDA_Y1 + 0.5 + kalip_duvar - S_UST]);
module kalip_2d() union() { offset(r = cep_bosluk + kalip_duvar) DIS(); dil_2d(); }

// --------------------------------------------------------------- levha
module kafes_2d() intersection() {
    offset(r = -kafes_kenar) IC();
    N = ceil(max(IC_EN, IC_BOY) / kafes_adim) + 2;
    a = kafes_adim;  sat = a * sqrt(3) / 2;
    for (j = [-N : N], i = [-N : N]) translate([i * a + (j % 2 == 0 ? 0 : a / 2), j * sat])
        rotate(30) circle(d = (a - kafes_cubuk) / cos(30), $fn = 6);
}
module levha() {
    difference() {
        union() {
            linear_extrude(kalinlik) union() {
                DIS();
                boyun_2d();
            }
            // çerçeve: dış hat boyunca rim_en genişliğinde, rim_h yüksekliğinde
            linear_extrude(rim_h) difference() { DIS(); offset(r = -rim_en) DIS(); }
        }
        translate([0, 0, -1]) linear_extrude(kalinlik + 2) kafes_2d();
    }
    yarim_vida();
}

// ------------------------------------------------------------ dişi kalıp
// Kalıp ağzı yukarıda. Levha çerçevesi aşağı bakacak şekilde cebe konur,
// çerçeve oluğa girer. Kabuk aşağı kabarır.
CEP = kalinlik + C;                       // cep derinliği (0,7)
PF  = kalip_taban + D + kalinlik + C;     // cep tabanı (levhanın çerçeve yüzü burada)
H_D = PF + CEP;                           // dişi kalıp yüksekliği
// kabuk koordinatından dişi koordinatına: z_d = PF + kalinlik - z
module kabuktan_disiye() translate([0, 0, PF + kalinlik]) mirror([0, 0, 1]) children();
module disi() difference() {
    linear_extrude(H_D) kalip_2d();
    // levha cebi (boyun dahil)
    translate([0, 0, PF]) linear_extrude(H_D) offset(r = cep_bosluk) union() { DIS(); boyun_2d(); }
    // çerçeve oluğu
    translate([0, 0, PF - (rim_h - kalinlik) - C]) linear_extrude(rim_h)
        difference() { offset(r = cep_bosluk) DIS(); offset(r = -rim_en - cep_bosluk) DIS(); }
    // şekil boşluğu = kabuğun dış yüzü + C
    kabuktan_disiye() kabuk_dis(C);
    // yarım vida yatağı: vidanın tam boyunca yarım silindir, ucu kapalı.
    // Çerçeve ve oluk kesintisiz kalır; yatak vidanın başladığı yerden başlar.
    translate([0, VIDA_Y0 - 0.2, PF + kalinlik]) rotate([-90, 0, 0])
        cylinder(d = vida_d + 0.6, h = vida_boy + 0.7, $fn = 64);
}
// Kabuğun dış yüzü: iç hacmin her yanı levha kalınlığı kadar dışarıda
module kabuk_dis(e) for (i = [0 : N_KAT - 1]) {
    Dd = D + kalinlik;
    z0 = Dd * i / N_KAT;  z1 = Dd * (i + 1) / N_KAT;
    translate([0, 0, i == 0 ? -0.5 : z0]) linear_extrude(z1 - z0 + (i == 0 ? 0.5 : 0) + 0.001)
        offset(r = kalinlik + e - ins(min(D, z1))) IC();
}

// ------------------------------------------------------------ erkek kalıp
// Taban plakası dişi kalıbın tam üstüne oturur; çıkıntı = kabuğun iç yüzü − C.
// Tabla üstünde: plaka altta, çıkıntı yukarıda. Kullanırken ters çevrilir.
T_E = 2.2;
module erkek() {
    // taban plakası dişinin dilini de örter: vidanın düz yüzünü baştan sona bastırır
    linear_extrude(T_E) kalip_2d();
    // kabuk koordinatı z → erkek z: T_E + C + z  (z = -C'den başlar)
    translate([0, 0, T_E + C]) intersection() {
        ic_hacim(-C);
        translate([-100, -100, -C - 0.01]) cube([200, 200, D]);
    }
    translate([0, 0, T_E - 0.01]) linear_extrude(C + 0.02) offset(r = -C) IC();
}

// --------------------------------------------------------------- kıskaç
// U kıskaç: iki kabuğun çerçevelerini dıştan kavrar. Çene uçlarındaki küçük
// tırnaklar çerçevenin iç kenarından aşağı iner, kıskacı yerinde tutar.
K_AGIZ = 2*rim_h + kiskac_bosluk;          // 4,2
K_ET = 1.2;
K_CENE = rim_en + 0.5;                      // çerçeve + 0,1 boşluk + 0,4 tırnak
K_TIRNAK = 0.3;
module kiskac_2d() {
    m = K_AGIZ/2;
    difference() {
        translate([0, -m - K_ET]) square([K_ET + K_CENE, K_AGIZ + 2*K_ET]);
        translate([K_ET, -m]) square([K_CENE + 1, K_AGIZ]);
    }
    // dik yüz çerçevenin iç kenarına dayanır (kilit), uca doğru pahlı (takarken kayar)
    x0 = K_ET + rim_en + 0.1;
    for (s = [1, -1]) scale([1, s])
        polygon([[x0, m + 0.01], [x0, m - K_TIRNAK], [x0 + 0.15, m - K_TIRNAK], [x0 + 0.4, m + 0.01]]);
}
module kiskac() linear_extrude(kiskac_en) kiskac_2d();

// ---------------------------------------------------------------- somun
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

// ------------------------------------------------------- kapalı önizleme
module kabuk() {
    color("White", 0.9) intersection() {
      translate([-100, -100, 0]) cube([200, 200, 50]);
      difference() {
        union() {
            kabuk_dis(0);
            linear_extrude(kalinlik) DIS();
            linear_extrude(rim_h) difference() { DIS(); offset(r = -rim_en) DIS(); }
        }
        ic_hacim(0);
      }
    }
    color("White") yarim_vida();
}
module kapali() {
    kabuk();
    rotate([0, 180, 0]) kabuk();
    color("Orange") translate([0, VIDA_Y0 + 0.5, 0]) rotate([-90, 0, 0]) somun();
}

if      (parca == "levha")  levha();
else if (parca == "disi")   disi();
else if (parca == "erkek")  erkek();
else if (parca == "kiskac") kiskac();
else if (parca == "somun")  somun();
else if (parca == "kapali") kapali();
else if (parca == "ic")     ic_hacim(0);          // denetim
else if (parca == "kabuk")  kabuk();              // denetim
