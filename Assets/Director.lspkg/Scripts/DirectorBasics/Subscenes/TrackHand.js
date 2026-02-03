//@input SceneObject parent
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Tracking hand: 1 - Right, 2 - Left"}
//@input Component.ObjectTracking3D[] handTracking
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Parent of the Mesh: 1 - Right, 2 - Left"}
//@input SceneObject[] meshParent
//@ui {"widget":"separator"}
//@input float lerpSpeedMovement = 0.4
//@input float lerpSpeedRotation = 0.4
//@input float scaleDuration = 1
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Parent of the Head Position: 1 - Top, 2 - Bot"}
//@input SceneObject[] headParentPositions

// index 0 = main droite
// index 1 = main gauche

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//

// By default: no hand is detected
var RightHandDetected = false;
var LeftHandDetected = false;

var rightTargetReached = false;
var leftTargetReached = false;

//________Caller________//
// 0 = undetected, 1 = detected
const enableDetectionCaller = script.subScene.CreateCaller(
  "EnableDetectionEvent",
  0,
);
const RightHandCaller = script.subScene.CreateCaller("RightHandEvent", 0);
const LeftHandCaller = script.subScene.CreateCaller("LeftHandEvent", 0);

//________Listener________//
const targetReachedListener = script.subScene.CreateListener(
  "targetReachedEvent",
  OnTargetReached,
);

//__________________________Animations____________________________//

var meshToAnimate = null;
// SCALE ANIMATION
var scaleAnim = new global.Animation(
  script.parent,
  script.scaleDuration,
  ScaleAnimUpdate,
);
scaleAnim.Easing = BounceOut;
function ScaleAnimUpdate(ratio) {
  var scaleValue = ratio;
  var transform = meshToAnimate.getTransform();
  transform.setLocalScale(new vec3(scaleValue, scaleValue, scaleValue));
}

scaleAnim.AddTimeCodeEvent(1, function () {
  enableDetectionCaller.Call(1);
});

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {
  // Disable mesh parent Right
  script.meshParent[0].enabled = false;
  // Disable mesh parent Left
  script.meshParent[1].enabled = false;
}

function Update() {
  // Check each hand tracker
  script.handTracking.forEach((handTracker, index) => {
    // If hand is tracking
    if (handTracker.isTracking()) {
      // If right hand and not yet detected
      if (index === 0) {
        if (!RightHandDetected) {
          console.log("Right Hand Detected");
          RightHandDetected = true;

          // First set position and rotation without lerp
          script.meshParent[0].enabled = true;
          setPositionAndRotation(handTracker, script.meshParent[index]);
          meshToAnimate = script.meshParent[0];
          scaleAnim.Start();
          RightHandCaller.Call(1);
        }

        // while right target not reached -> follow hand
        if (!rightTargetReached) {
          lerpPositionAndRotation(handTracker, script.meshParent[0]);
        } else {
          lerpPositionAndRotation(
            script.headParentPositions[0],
            script.meshParent[0],
          );
        }
      }
      // If left hand and not yet detected
      else if (index === 1) {
        if (!LeftHandDetected) {
          console.log("Left Hand Detected");
          LeftHandDetected = true;

          // First set position and rotation without lerp
          script.meshParent[1].enabled = true;
          setPositionAndRotation(handTracker, script.meshParent[index]);
          meshToAnimate = script.meshParent[1];
          scaleAnim.Start();
          LeftHandCaller.Call(1);
        }
        if (!leftTargetReached) {
          lerpPositionAndRotation(handTracker, script.meshParent[1]);
        } else {
          lerpPositionAndRotation(
            script.headParentPositions[1],
            script.meshParent[1],
          );
        }
      }
    }
    // If hand is not tracking
    else {
      // If right hand was detected
      if (index === 0 && RightHandDetected) {
        if (!rightTargetReached) {
          RightHandDetected = false;
          RightHandCaller.Call(0);
          script.meshParent[0].enabled = false;
        } else {
          lerpPositionAndRotation(
            script.headParentPositions[0],
            script.meshParent[0],
          );
        }
        console.log("Right Hand Lost");
      }
      // If left hand was detected
      else if (index === 1 && LeftHandDetected) {
        console.log("Left Hand Lost");
        if (!leftTargetReached) {
          LeftHandDetected = false;
          LeftHandCaller.Call(0);
          script.meshParent[1].enabled = false;
        } else {
          lerpPositionAndRotation(
            script.headParentPositions[1],
            script.meshParent[1],
          );
        }
      }
    }
  });
}

function Stop() {
  RightHandDetected = false;
  LeftHandDetected = false;

  // Disable mesh parent Right
  script.meshParent[0].enabled = false;
  // Disable mesh parent Left
  script.meshParent[1].enabled = false;

  rightTargetReached = false;
  leftTargetReached = false;
}

//___________________________Functions__________________________//

function lerpPositionAndRotation(handTracker, meshParent) {
  var handTransform = handTracker.getTransform();

  // LERP POSITION
  var handPos = handTransform.getWorldPosition();
  var currentPos = meshParent.getTransform().getWorldPosition();
  var lerpPos = vec3.lerp(currentPos, handPos, script.lerpSpeedMovement);
  meshParent.getTransform().setWorldPosition(lerpPos);

  // LERP ROTATION
  var handRot = handTransform.getWorldRotation();
  var currentRot = meshParent.getTransform().getWorldRotation();
  var lerpRot = quat.slerp(currentRot, handRot, script.lerpSpeedRotation);
  meshParent.getTransform().setWorldRotation(lerpRot);
}

function setPositionAndRotation(handTracker, meshParent) {
  var handTransform = handTracker.getTransform();
  // SET POSITION
  var handPos = handTransform.getWorldPosition();
  meshParent.getTransform().setWorldPosition(handPos);
  // SET ROTATION
  var handRot = handTransform.getWorldRotation();
  meshParent.getTransform().setWorldRotation(handRot);
}

function OnTargetReached(value) {
  // value 0 = right, 1 = left
  if (value === 0) {
    rightTargetReached = true;
  } else if (value === 1) {
    leftTargetReached = true;
  }
}
