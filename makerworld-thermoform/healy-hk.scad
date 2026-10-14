// =====================================================================
//  Healy kılıfı — HELLO KITTY YÖNTEMİ (makerworld 3433672 setinden ölçüldü)
//
//  Parçalar:
//    - Dişi kalıp (alt): boşluk = kabuğun dış yüzü. Ağzında levha cebi
//      (1 mm) ve kilit kaburgası oluğu (boşluğun 1,5 mm dışında, 2 mm geniş).
//    - Erkek kalıp (üst): 3 mm taban + yastık şeklinde çıkıntı = kabuğun iç
//      yüzü. Tabanı dişinin üstüne oturunca aradaki boşluk tam levha kalınlığı.
//    - Levha: 0,8 mm, en dış kenarda 1,65 × 4 mm kilit kaburgası.
//  Şekil: yastık — düz yüz + R yarıçaplı yuvarlak kenar (esneme kenara yayılır).
//
//  Eklenenler (kalıbı etkileyenler):
//    - V açıklığı: levha V'de önceden kesik basılır (healy-hk-vkes.py hesaplar);
//      kalıplar düz yastık kalır. Kabukta cihazın V çentiğinin önü açık olur.
//    - Üstte yarım vida (Ø10, iki ağızlı, 9 mm, ucu pahlı) + askılı somun;
//      dişi kalıpta vida yatağı, erkek kalıbın tabanı vidanın düz yüzünü bastırır.
//    - Yanlarda iki kabuğun kaburgalarını kavrayan U kıskaç (kalıba etkisi yok).
//
//  Kabuk koordinatı t: t = 0 levhanın birleşme yüzü (iç yüz), kabuk −z'ye kabarır.
// =====================================================================

/* [Parça] */
parca = "disi"; // [disi, erkek, levha, kiskac, somun, kabuk, ic, kapali]

/* [Cihaz] */
cihaz_en = 56;
cihaz_boy = 58;
cihaz_h = 18.5;
cihaz_kose = 6;

/* [Yastık şekli] */
R = 10;            // kenar yuvarlaması (Hello Kitty ~10)
D = 11.5;          // kabuk iç derinliği (cihaz yarısı 9,25 + pay)
yan_pay = 3.2;     // cihazın çevresinde iç boşluk (R10 için, kenarı r2,5–3,5 cihaz sığar)
plan_kose = 10;    // iç hattın köşe yarıçapı (üstten bakış)

/* [Levha — Hello Kitty] */
kalinlik = 0.8;
kaburga_en = 1.65;
kaburga_h = 4.0;          // toplam (levha dahil)

/* [Kalıp — Hello Kitty] */
oluk_ara = 1.5;           // boşluk kenarı ile oluk arası
oluk_pay = 0.175;         // kaburganın oluktaki yan boşluğu (2 mm oluk)
cep_derin = 1.0;          // levha cebi (0,8 levha + 0,2)
dis_duvar = 9.6;          // boşluk kenarından dişi kalıbın dış kenarına
disi_taban = 5;           // boşluk altındaki taban
erkek_taban = 3;

/* [Vida ve somun] */
vida_d = 10;
vida_adim = 2;
vida_boy = 9;
vida_pah = 1.0;
somun_bosluk = 0.6;
halka_d = 10;
halka_delik = 4.5;

/* [Kıskaç] */
kiskac_en = 5;

/* [Hidden] */
include <healy-hk-vkes.scad>
$fn = 64;
N = 60;
IC_EN  = cihaz_en  + 2*yan_pay;
IC_BOY = cihaz_boy + 2*yan_pay;
module IC() offset(r = plan_kose) square([IC_EN - 2*plan_kose, IC_BOY - 2*plan_kose], center = true);
// derinlik t'deki içe çekilme (iç yüz, R) ve dış yüz (R + kalinlik)
function ins(t, r, d) = t <= d - r ? 0 : r - sqrt(max(0, r*r - pow(t - (d - r), 2)));

// İç yastık (erkek çıkıntı = kabuğun iç yüzü): t = 0 .. D, −z yönünde
module ic_yastik(e = 0) for (i = [0 : N - 1]) {
    t1 = D * (i + 1) / N;  t0 = D * i / N;
    translate([0, 0, -t1]) linear_extrude(t1 - t0 + 0.001) offset(r = e - ins(t1, R, D)) IC();
}
// Dış yastık (kabuğun dış yüzü): plan IC + kalinlik, derinlik D + kalinlik, yarıçap R + kalinlik
module dis_yastik() for (i = [0 : N - 1]) {
    Dd = D + kalinlik;  Rr = R + kalinlik;
    t1 = Dd * (i + 1) / N;  t0 = Dd * i / N;
    translate([0, 0, -t1]) linear_extrude(t1 - t0 + 0.001)
        offset(r = kalinlik - ins(t1, Rr, Dd)) IC();
}
BOS = kalinlik;                                   // boşluk kenarı: IC + kalinlik
OLUK_IC = BOS + oluk_ara;                         // oluğun iç kenarı (IC'den)
P_OFS = OLUK_IC + oluk_pay + kaburga_en;          // levhanın dış kenarı (IC'den)
OLUK_DIS = P_OFS + oluk_pay;
DIS_OFS = BOS + dis_duvar;

// ----------------------------------------------------------------- levha
// Baskıda: levha tablada, kaburga yukarı. Kalıba kaburga AŞAĞI konur.
module VKES() polygon(VKES_PTS);                          // levhada önceden kesilen V
module P_2d() difference() { union() { offset(r = P_OFS) IC(); boyun_2d(); } VKES(); }
module kaburga_2d() difference() { offset(r = P_OFS) IC(); offset(r = P_OFS - kaburga_en) IC(); offset(delta = 0.01) VKES(); }
module levha() {
    linear_extrude(kalinlik) P_2d();
    linear_extrude(kaburga_h) kaburga_2d();
    yarim_vida();
}

// ------------------------------------------------------------------ vida
// Levha baskı koordinatında: ekseni +y, z = 0 (levhanın birleşme yüzü) üzerinde.
DIS_H = vida_adim * 0.35;
LEAD = 2 * vida_adim;                                     // iki ağızlı
VIDA_Y0 = IC_BOY/2 + P_OFS - kaburga_en;                  // kaburganın içinden başlar
VIDA_Y1 = VIDA_Y0 + vida_boy;
BOYUN_EN = vida_d - 2*DIS_H;
module boyun_2d() translate([-BOYUN_EN/2, IC_BOY/2]) square([BOYUN_EN, VIDA_Y1 - IC_BOY/2]);
module dis2(d, L) linear_extrude(L, twist = -360 * L / LEAD, slices = ceil(L / LEAD * 36))
    scale([1, (d - 2*DIS_H) / d]) circle(d = d, $fn = 64);
module tam_vida() translate([0, VIDA_Y0, 0]) rotate([-90, 0, 0]) intersection() {
    dis2(vida_d, vida_boy);
    // uçta pah: somun kolay başlasın
    union() { cylinder(d = vida_d + 1, h = vida_boy - vida_pah);
              translate([0, 0, vida_boy - vida_pah - 0.001]) cylinder(d1 = vida_d + 1, d2 = vida_d - 2*vida_pah, h = vida_pah + 0.002); }
}
module yarim_vida() intersection() {
    tam_vida();
    translate([-vida_d, VIDA_Y0 - 1, 0]) cube([2*vida_d, vida_boy + 2, vida_d]);
}
SOMUN_H = vida_boy - 1;
SOMUN_D = vida_d + 5;
module somun() {
    difference() {
        cylinder(d = SOMUN_D, h = SOMUN_H, $fn = 8);
        translate([0, 0, -1]) dis2(vida_d + somun_bosluk, SOMUN_H + 2);
        translate([0, 0, -0.01]) cylinder(d1 = vida_d + 1.6, d2 = vida_d - 0.4, h = 1.2);
    }
    translate([0, 0, SOMUN_H - 0.01]) cylinder(d = SOMUN_D, h = 1.2, $fn = 8);
    translate([0, 0, SOMUN_H + 1.2 + halka_d/2 - 1]) rotate([0, 90, 0])
        linear_extrude(3, center = true) difference() { circle(d = halka_d); circle(d = halka_delik); }
}

// --------------------------------------------------------------- kıskaç
// İki kabuğun kaburgalarını (2 × 4 mm) yandan kavrayan U; uçta 0,2 mm tırnak.
K_AGIZ = 2 * kaburga_h;
K_ET = 1.6;  K_CENE = kaburga_en + 0.6;
module kiskac_2d() {
    difference() {
        translate([0, -K_AGIZ/2 - K_ET]) square([K_ET + K_CENE, K_AGIZ + 2*K_ET]);
        translate([K_ET, -K_AGIZ/2]) square([K_CENE + 1, K_AGIZ]);
    }
    for (s = [1, -1]) scale([1, s]) translate([K_ET + kaburga_en + 0.05, K_AGIZ/2])
        polygon([[0, 0.01], [0.15, -0.2], [0.4, -0.2], [0.55, 0.01]]);
}
module kiskac() linear_extrude(kiskac_en) kiskac_2d();

// ------------------------------------------------------------- dişi kalıp
// Dişi koordinatı: üst yüz z = H_D. Levhanın iç yüzü (t = 0) z = H_D − (cep_derin − kalinlik).
H_D = disi_taban + D + kalinlik + cep_derin;
Z0 = H_D - (cep_derin - kalinlik);                // t = 0 düzlemi
DIL_EN = vida_d + 0.6 + 6;
module dil_2d() translate([-DIL_EN/2, 0]) square([DIL_EN, VIDA_Y1 + 0.5 + 3]);   // vidayı taşıyan dil
module kalip_2d() union() { offset(r = DIS_OFS) IC(); dil_2d(); }
module disi() difference() {
    linear_extrude(H_D) kalip_2d();
    // levha cebi (boyun dahil)
    translate([0, 0, H_D - cep_derin]) linear_extrude(cep_derin + 1)
        union() { offset(r = OLUK_DIS + 0.3) IC(); offset(delta = 0.3) boyun_2d(); }
    // yarım vida yatağı: düz yüzü t = 0'da, yuvarlak tarafı aşağıda; ucu kapalı
    translate([0, VIDA_Y0 - 0.2, Z0]) rotate([-90, 0, 0]) cylinder(d = vida_d + 0.6, h = vida_boy + 0.7);
    // kaburga oluğu
    translate([0, 0, H_D - cep_derin - (kaburga_h - kalinlik) - 0.5])
        linear_extrude(kaburga_h) difference() { offset(r = OLUK_DIS) IC(); offset(r = OLUK_IC) IC(); }
    // şekil boşluğu = kabuğun dış yüzü (levhanın dış yüzü cep tabanında)
    translate([0, 0, Z0]) { dis_yastik(); translate([0, 0, -kalinlik - 0.01]) linear_extrude(kalinlik + 1) offset(r = kalinlik) IC(); }
}

// ------------------------------------------------------------ erkek kalıp
// Baskıda: taban tablada, çıkıntı yukarı. Kullanırken ters çevrilir;
// tabanı dişinin üst yüzüne oturur.
module erkek() mirror([0, 0, 1]) translate([0, 0, -H_D - erkek_taban]) {
    translate([0, 0, H_D]) linear_extrude(erkek_taban) kalip_2d();
    translate([0, 0, Z0]) { ic_yastik(); linear_extrude(H_D - Z0 + 0.01) IC(); }
}
// Kullanım konumunda erkek (doğrulama için)
module erkek_yerinde() {
    translate([0, 0, H_D]) linear_extrude(erkek_taban) kalip_2d();
    translate([0, 0, Z0]) { ic_yastik(); linear_extrude(H_D - Z0 + 0.01) IC(); }
}

// ------------------------------------------------ şekillenmiş kabuk (dişi koordinatında)
// Hedef V açıklığı (cihazın çentiği + 1 mm): kabukta bu prizmanın içi açık
module V_HEDEF() offset(r = 1) offset(r = 1.5) offset(delta = -1.5)
    polygon([[-18.5, -60], [18.5, -60], [18.5, -30], [0, -19], [-18.5, -30]]);
module kabuk_yerinde() {
  difference() {
    union() {
        translate([0, 0, Z0]) dis_yastik();
        translate([0, 0, Z0 - kalinlik]) linear_extrude(kalinlik) P_2d();
        translate([0, 0, Z0 - kaburga_h]) linear_extrude(kaburga_h - kalinlik + 0.01) kaburga_2d();
        translate([0, 0, Z0]) mirror([0, 0, 1]) yarim_vida();
    }
    translate([0, 0, Z0]) ic_yastik();
    translate([0, 0, Z0 - 0.01]) linear_extrude(1) IC();
    translate([0, 0, -1]) linear_extrude(H_D + 2) V_HEDEF();
  }
}
// Kabuk kendi koordinatında (t = 0 birleşme yüzü z = 0, kabuk −z)
module kabuk() translate([0, 0, -Z0]) kabuk_yerinde();

if      (parca == "disi")   disi();
else if (parca == "erkek")  erkek();
else if (parca == "erkek_yerinde") erkek_yerinde();
else if (parca == "levha")  levha();
else if (parca == "kabuk")  kabuk();
else if (parca == "kabuk_yerinde") kabuk_yerinde();
else if (parca == "ic")     translate([0, 0, 0]) ic_yastik();
else if (parca == "kiskac") kiskac();
// 3MF için levhanın ayrı ayarlı parçaları: levha+kaburga (desenli) ve yarım vida (dolu)
else if (parca == "levha_govde") { linear_extrude(kalinlik) P_2d(); linear_extrude(kaburga_h) kaburga_2d(); }
else if (parca == "vida") yarim_vida();
else if (parca == "somun")  somun();
else if (parca == "tam_vida") tam_vida();
else if (parca == "kapali") { kabuk(); rotate([0, 180, 0]) kabuk(); }
