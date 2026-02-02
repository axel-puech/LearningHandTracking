//@input SceneObject parent
//@ui {"widget":"label", "label":"Fire Aura: 1 - Right, 2 - Left"}
//@input Component.VFXComponent[] ParticlesRightLeft

// prend juste les deux screen Image et les fait tourner sur elle meme

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//

var activateParticlesRight = false;
var activateParticlesLeft = false;
//________DelayEvent________//
// var deleteParticlesRightEvent = script.subScene.CreateEvent(
//   "DelayedCallbackEvent",
//   ToggleParticlesRight,
// );

//________Listener________//
var RightHandCaller = script.subScene.CreateListener(
  "RightHandEvent",
  ToggleParticlesRight,
);
var LeftHandCaller = script.subScene.CreateListener(
  "LeftHandEvent",
  ToggleParticlesLeft,
);

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {
  // Deactivate all particles at start
  script.ParticlesRightLeft[0].asset.properties["killParticles"] = 1;
  script.ParticlesRightLeft[1].asset.properties["killParticles"] = 1;
}

function Update() {}

function Stop() {}

//___________________________Functions__________________________//

function ToggleParticlesRight(value) {
  if (value === 1 && !activateParticlesRight) {
    activateParticlesRight = true;
    script.ParticlesRightLeft[0].asset.properties["killParticles"] = 0;

    print("Activate Right Particles");
  } else if (value === 0 && activateParticlesRight) {
    activateParticlesRight = false;
    script.ParticlesRightLeft[0].asset.properties["killParticles"] = 1;
    print("Deactivate Right Particles");
  }
}

function ToggleParticlesLeft(value) {
  if (value === 1 && !activateParticlesLeft) {
    activateParticlesLeft = true;
    script.ParticlesRightLeft[1].asset.properties["killParticles"] = 0;
    print("Activate Left Particles");
  } else if (value === 0 && activateParticlesLeft) {
    activateParticlesLeft = false;
    script.ParticlesRightLeft[1].asset.properties["killParticles"] = 1;
    print("Deactivate Left Particles");
  }
}
