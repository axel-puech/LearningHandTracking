//@input SceneObject parent
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Head Material"}
//@input Asset.Material headMaterial
//@input float fadeDuration = 1

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//
//________Listener________//
// 0 = right, 1 = left
const targetReachedListener = script.subScene.CreateListener(
  "targetReachedEvent",
  OnTargetReached,
);

var isTargetRightReached = false;
var isTargetLeftReached = false;
var hasAnimationStarted = false;

//__________________________Animations____________________________//
// FADE ANIMATION
var fadeAnim = new global.Animation(
  script.parent,
  script.fadeDuration,
  FadeAnimUpdate,
);

function FadeAnimUpdate(ratio) {
  script.headMaterial.mainPass.alphaHeadMaterial = ratio;
}

//_________________________Director functions_____________________//

function Start() {
  fadeAnim.JumpTo(0);
}
function OnLateStart() {}

function Update() {
  // var alpha = script.headMaterial.mainPass.alphaHeadMaterial;
  // print("Head Alpha: " + alpha);
}

function Stop() {
  isTargetRightReached = false;
  isTargetLeftReached = false;
  hasAnimationStarted = false;
  fadeAnim.Reset();
}

//___________________________Functions__________________________//

function OnTargetReached(index) {
  if (index === 0) {
    isTargetRightReached = true;
  } else if (index === 1) {
    isTargetLeftReached = true;
  }
  if (isTargetRightReached && isTargetLeftReached && !hasAnimationStarted) {
    hasAnimationStarted = true;
    fadeAnim.Start();
  }
}
