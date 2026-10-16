// Kıskaç yuvası gösterimi (healy-hk.scad üzerine)
include </home/user/claude-todo/makerworld-thermoform/healy-hk.scad>
goster = "kabuk_kulak";
KULAK_BOY = 7;   // kaburganın dışına uzanım
KULAK_EN = 10;   // kenar boyunca
YUVA_X = 2.2;    // dörtgen yuva (kenara dik)
YUVA_Y = 4.2;    // dörtgen yuva (kenar boyunca)
KX = IC_EN/2 + P_OFS;                         // kaburganın dış kenarı
module kulak_2d(s) translate([s*(KX + KULAK_BOY/2 - 0.5), 0])
    difference() { offset(r = 1.5) offset(delta = -1.5) square([KULAK_BOY + 1, KULAK_EN], center = true);
                   translate([s*0.5, 0]) square([YUVA_X, YUVA_Y], center = true); }
module kabuk_kulak() { kabuk(); for (s = [-1, 1]) translate([0, 0, -kalinlik]) linear_extrude(kalinlik) kulak_2d(s); }
// C kıskaç: iki kulağı (2 × kalınlık) kavrar, tırnaklar yuvaya girer
C_ET = 1.2; C_AGIZ = 2*kalinlik + 0.2; C_GEN = YUVA_Y - 0.5; TIRNAK = kalinlik * 0.8;
module c_kiskac() {
    m = C_AGIZ/2; derin = KULAK_BOY - 3.5 + YUVA_X/2 + 0.2;
    difference() { translate([0, -m - C_ET]) square([C_ET + derin, C_AGIZ + 2*C_ET]); translate([C_ET, -m]) square([derin + 1, C_AGIZ]); }
    x0 = C_ET + (KULAK_BOY - 3.5) - YUVA_X/2 + 0.2;
    for (q = [1, -1]) scale([1, q]) polygon([[x0, m + 0.01], [x0, m - TIRNAK], [x0 + (YUVA_X - 0.4)*0.4, m - TIRNAK], [x0 + YUVA_X - 0.4, m + 0.01]]);
}
module c3d() linear_extrude(C_GEN, center = true) c_kiskac();
if (goster == "kabuk_kulak") kabuk_kulak();
else if (goster == "kiskac") c3d();
else if (goster == "levha_kulak") { levha(); for (s = [-1, 1]) linear_extrude(kalinlik) kulak_2d(s); }
