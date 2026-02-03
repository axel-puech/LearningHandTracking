//@input SceneObject parent
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Fire Aura: 1 - Right, 2 - Left"}
//@input SceneObject[] imageObject
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Hand Tracking: 1 - Right, 2 - Left"}
//@input Component.ObjectTracking3D[] handTracking
//@ui {"widget":"separator"}
//@input Component.Camera cam
//@input float minimumDistance = 0.2

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

var enableDetection = false;

//________Listener________//
var RightHandListener = script.subScene.CreateListener(
  "RightHandEvent",
  ToggleRight,
);
var LeftHandListener = script.subScene.CreateListener(
  "LeftHandEvent",
  ToggleLeft,
);
const enableDetectionListener = script.subScene.CreateListener(
  "EnableDetectionEvent",
  ToggleEnableDetection,
);

//________Caller________//
// 0 = right, 1 = left
const targetReachedCaller = script.subScene.CreateCaller(
  "targetReachedEvent",
  0,
);

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {}

function Update() {
  if (RightHandDetected && enableDetection) {
    var handPosScreenRight = returnHandPosition(script.handTracking[0]);
    var distance = handPosScreenRight.distance(targetPosRight);
    if (distance < script.minimumDistance) {
      targetReachedCaller.Call(0);
    }
  }

  if (LeftHandDetected && enableDetection) {
    var handPosScreenLeft = returnHandPosition(script.handTracking[1]);
    var distance = handPosScreenLeft.distance(targetPosLeft);
    if (distance < script.minimumDistance) {
      targetReachedCaller.Call(1);
    }
  }
}

function Stop() {
  RightHandDetected = false;
  LeftHandDetected = false;

  enableDetection = false;
}

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

function ToggleEnableDetection(value) {
  if (value === 1) {
    print("Enable hand detection");
    enableDetection = true;
  } else {
    print("Disable hand detection");
    enableDetection = false;
  }
}
