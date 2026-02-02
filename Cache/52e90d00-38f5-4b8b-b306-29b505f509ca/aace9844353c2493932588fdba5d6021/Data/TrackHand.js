//@input SceneObject parent
//@input Component.ObjectTracking3D[] handTrackingRightLeft
//@input SceneObject[] meshParentRightLeft

// premmierement identifier si les mains sont detectees
// cette scene va prendre les tracking des deux mains
// track la position des mains et applique cette position aux parents des meshes des mains
// cette scene va prendre aussi en input le parent des meshes des mains et des particles

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

//_________________________Director functions_____________________//

function Start() {
  print("TrackHand Subscene started");
}
function OnLateStart() {
  // Disable mesh parent Right
  script.meshParentRightLeft[0].enabled = false;
  // Disable mesh parent Left
  script.meshParentRightLeft[1].enabled = false;
}

function Update() {
  // Check each hand tracker
  script.handTrackingRightLeft.forEach((handTracker, index) => {
    // If hand is tracking
    if (handTracker.isTracking()) {
      // If right hand and not yet detected
      var rightHandTransform = handTracker.getTransform();
      if (index === 0 && !RightHandDetected) {
        console.log("Right Hand Detected");
        RightHandDetected = true;
        script.meshParentRightLeft[0].enabled = true;
      }
      // If left hand and not yet detected
      else if (index === 1) {
        if (!LeftHandDetected) {
          console.log("Left Hand Detected");
          LeftHandDetected = true;
          script.meshParentRightLeft[1].enabled = true;
        }
      }
    }
    // If hand is not tracking
    else {
      // If right hand was detected
      if (index === 0 && RightHandDetected) {
        console.log("Right Hand Lost");
        RightHandDetected = false;
        script.meshParentRightLeft[0].enabled = false;
      }
      // If left hand was detected
      else if (index === 1 && LeftHandDetected) {
        console.log("Left Hand Lost");
        LeftHandDetected = false;
        script.meshParentRightLeft[1].enabled = false;
      }
    }
  });
}

function Stop() {
  RightHandDetected = false;
  LeftHandDetected = false;
  // Disable mesh parent Right
  script.meshParentRightLeft[0].enabled = false;
  // Disable mesh parent Left
  script.meshParentRightLeft[1].enabled = false;
}

//___________________________Functions__________________________//
