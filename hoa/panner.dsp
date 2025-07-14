declare name "panner";
declare version "1.0";
declare author "CICM";
declare license "BSD";
declare copyright "(c)CICM 2013";

import("stdfaust.lib");

import("ambi.cnf");
//L=2;   //ambisonics order
//S=8;   //num sources
//N=12; //num speakers


mapper(l) = ho.map(L,r,a) with {
    ll=l+1;
    r = hslider("h:%ll/[style:knob]radius", 1.0, 0, 5, 0.001) : si.smooth(ba.tau2pole(0.02));
    a = hslider("h:%ll/[style:knob]angle", 0, ma.PI*(-2), ma.PI*2, 0.001) : si.smooth(ba.tau2pole(0.02));
    //g = hslider("h:%ll/[style:knob]Gain", 1.0, 0, 5, 0.001) : si.smooth(ba.tau2pole(0.02));
};

/*
r1 = hslider("h:[0]input1/Radius", 1.0, 0, 5, 0.001) : si.smooth(ba.tau2pole(0.02));
a1 = hslider("h:[0]input1/Angle", 0, ma.PI*(-2), ma.PI*2, 0.001) : si.smooth(ba.tau2pole(0.02));
r2 = hslider("h:[1]input2/Radius", 1.0, 0, 5, 0.001) : si.smooth(ba.tau2pole(0.02));
a2 = hslider("h:[1]input2/Angle", 0, ma.PI*(-2), ma.PI*2, 0.001) : si.smooth(ba.tau2pole(0.02));
r3 = hslider("h:[2]input3/Radius", 1.0, 0, 5, 0.001) : si.smooth(ba.tau2pole(0.02));
a3 = hslider("h:[2]input3/Angle", 0, ma.PI*(-2), ma.PI*2, 0.001) : si.smooth(ba.tau2pole(0.02));
r4 = hslider("h:[3]input4/Radius", 1.0, 0, 5, 0.001) : si.smooth(ba.tau2pole(0.02));
a4 = hslider("h:[3]input4/Angle", 0, ma.PI*(-2), ma.PI*2, 0.001) : si.smooth(ba.tau2pole(0.02));
*/
process = par(i,S,hgroup("panner",mapper(i))):>si.bus(2*L+1);

//process(sig1, sig2, sig3, sig4) = ho.map(3, sig1, r1, a1), ho.map(3, sig2, r2, a2), ho.map(3, sig3, r3, a3), ho.map(3, sig4, r4, a4) :> ho.optimInPhase(3) : ho.decoder(3, 8);
