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
//  Bu dosya YÖNTEM denemesidir: V açıklığı, vida ve kıskaç henüz yok.
//
//  Kabuk koordinatı t: t = 0 levhanın birleşme yüzü (iç yüz), kabuk −z'ye kabarır.
// =====================================================================

/* [Parça] */
parca = "disi"; // [disi, erkek, levha, kabuk, ic, kapali]

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

/* [Hidden] */
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
module levha() {
    linear_extrude(kalinlik) offset(r = P_OFS) IC();
    linear_extrude(kaburga_h) difference() { offset(r = P_OFS) IC(); offset(r = P_OFS - kaburga_en) IC(); }
}

// ------------------------------------------------------------- dişi kalıp
// Dişi koordinatı: üst yüz z = H_D. Levhanın iç yüzü (t = 0) z = H_D − (cep_derin − kalinlik).
H_D = disi_taban + D + kalinlik + cep_derin;
Z0 = H_D - (cep_derin - kalinlik);                // t = 0 düzlemi
module disi() difference() {
    linear_extrude(H_D) offset(r = DIS_OFS) IC();
    // levha cebi
    translate([0, 0, H_D - cep_derin]) linear_extrude(cep_derin + 1) offset(r = OLUK_DIS + 0.3) IC();
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
    translate([0, 0, H_D]) linear_extrude(erkek_taban) offset(r = DIS_OFS) IC();
    translate([0, 0, Z0]) { ic_yastik(); linear_extrude(H_D - Z0 + 0.01) IC(); }
}
// Kullanım konumunda erkek (doğrulama için)
module erkek_yerinde() {
    translate([0, 0, H_D]) linear_extrude(erkek_taban) offset(r = DIS_OFS) IC();
    translate([0, 0, Z0]) { ic_yastik(); linear_extrude(H_D - Z0 + 0.01) IC(); }
}

// ------------------------------------------------ şekillenmiş kabuk (dişi koordinatında)
module kabuk_yerinde() difference() {
    union() {
        translate([0, 0, Z0]) dis_yastik();
        translate([0, 0, Z0 - kalinlik]) linear_extrude(kalinlik) offset(r = P_OFS) IC();
        translate([0, 0, Z0 - kaburga_h]) linear_extrude(kaburga_h - kalinlik + 0.01)
            difference() { offset(r = P_OFS) IC(); offset(r = P_OFS - kaburga_en) IC(); }
    }
    translate([0, 0, Z0]) ic_yastik();
    translate([0, 0, Z0 - 0.01]) linear_extrude(1) IC();
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
else if (parca == "kapali") { kabuk(); mirror([0, 0, 1]) kabuk(); }
