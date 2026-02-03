//@input SceneObject parent
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Particles: 1 - Right, 2 - Left"}
//@input Component.VFXComponent[] Particles

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
var RightHandListener = script.subScene.CreateListener(
  "RightHandEvent",
  ToggleParticlesRight,
);
var LeftHandListener = script.subScene.CreateListener(
  "LeftHandEvent",
  ToggleParticlesLeft,
);

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {
  // Deactivate all particles at start
  script.Particles[0].asset.properties["killParticles"] = 1;
  script.Particles[1].asset.properties["killParticles"] = 1;
}

function Update() {}

function Stop() {
  activateParticlesRight = false;
  activateParticlesLeft = false;
}

//___________________________Functions__________________________//

function ToggleParticlesRight(value) {
  if (value === 1 && !activateParticlesRight) {
    activateParticlesRight = true;
    script.Particles[0].asset.properties["killParticles"] = 0;

    print("Activate Right Particles");
  } else if (value === 0 && activateParticlesRight) {
    activateParticlesRight = false;
    script.Particles[0].asset.properties["killParticles"] = 1;
    print("Deactivate Right Particles");
  }
}

function ToggleParticlesLeft(value) {
  if (value === 1 && !activateParticlesLeft) {
    activateParticlesLeft = true;
    script.Particles[1].asset.properties["killParticles"] = 0;
    print("Activate Left Particles");
  } else if (value === 0 && activateParticlesLeft) {
    activateParticlesLeft = false;
    script.Particles[1].asset.properties["killParticles"] = 1;
    print("Deactivate Left Particles");
  }
}
