// generate particles arround the logo
//@input SceneObject parent
//@input Component.VFXComponent Particles

script.subScene = new global.SubScene(script, script.parent);

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {
  script.Particles.asset.properties["killParticles"] = 0;
}

function Update() {}
function Stop() {
  script.Particles.asset.properties["killParticles"] = 1;
}
