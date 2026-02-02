//@input SceneObject parent
//@ui {"widget":"label", "label":"Fire Aura: 1 - Right, 2 - Left"}
//@input SceneObject[] imageObject
//@ui {"widget":"label", "label":"Hand Tracking: 1 - Right, 2 - Left"}
//@input Component.ObjectTracking3D[] handTrackingRightLeft
//@input Component.Camera cam
// prend chaque screen Image
// prend chaque position des mains
// calcule que si la main est active ( cf event hand detected )

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//

var RightHandDetected = false;
var LeftHandDetected = false;

var targetPosRight = new vec2(0.15, 0.15);
var targetPosLeft = new vec2(0.85, 0.85);

//________Listener________//
var RightHandListener = script.subScene.CreateListener(
  "RightHandEvent",
  ToggleRight,
);
var LeftHandListener = script.subScene.CreateListener(
  "LeftHandEvent",
  ToggleLeft,
);

// creation des caller -> quand la main est proche de la cible
// const contactRight = script.subScene.CreateCaller("RightHandEvent", 0);
// const LeftHandCaller = script.subScene.CreateCaller("LeftHandEvent", 0);

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {}

function Update() {
  if (RightHandDetected) {
    var handPosScreenRight = returnHandPosition(
      script.handTrackingRightLeft[0],
    );
    var distance = handPosScreenRight.distance(targetPosRight);
    if (distance < 0.2) {
      print("Distance to target Right: " + distance);
    }

    // screenPosRight.distance();
  }

  if (LeftHandDetected) {
    var handPosScreenLeft = returnHandPosition(script.handTrackingRightLeft[1]);
    var distance = handPosScreenLeft.distance(targetPosLeft);
    if (distance < 0.2) {
      print("Distance to target Left: " + distance);
    }
  }
}

function Stop() {}

//___________________________Functions__________________________//

function ToggleRight(value) {
  if (value === 1 && !RightHandDetected) {
    RightHandDetected = true;
  } else if (value === 0 && RightHandDetected) {
    RightHandDetected = false;
  }
}

function ToggleLeft(value) {
  if (value === 1 && !LeftHandDetected) {
    LeftHandDetected = true;
  } else if (value === 0 && LeftHandDetected) {
    LeftHandDetected = false;
  }
}

function returnHandPosition(handTracking) {
  var handTrackingTr = handTracking.getTransform();
  var handPos = handTrackingTr.getWorldPosition();
  var screenPos = script.cam.worldSpaceToScreenSpace(handPos);
  return screenPos;
}
