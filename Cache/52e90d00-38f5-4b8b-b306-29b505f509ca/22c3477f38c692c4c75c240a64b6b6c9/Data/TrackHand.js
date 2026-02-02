//@input SceneObject parent
//@input Component.ObjectTracking3D[] handTrackingRightLeft
//@input SceneObject[] meshParentRightLeft

// premmierement identifier si les mains sont detectees
// cette scene va prendre les tracking des deux mains
// track la position des mains et applique cette position aux parents des meshes des mains
// cette scene va prendre aussi en input le parent des meshes des mains et des particles

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//

var RightHandDetected = false;
var LeftHandDetected = false;

//_________________________Director functions_____________________//

function Start() {
  print("TrackHand Subscene started");
}
function OnLateStart() {}

function Update() {
  script.handTrackingRightLeft.forEach((handTracker, index) => {
    if (handTracker.isTracking()) {
      if (index === 0) {
        if (!RightHandDetected) {
          console.log("Right Hand Detected");
          RightHandDetected = true;
          script.meshParentRightLeft[0].enabled = true;
        }
      } else if (index === 1) {
        if (!LeftHandDetected) {
          console.log("Left Hand Detected");
          LeftHandDetected = true;
          script.meshParentRightLeft[1].enabled = true;
        }
      }
    }
    else {
      if (index === 0) {
        if (RightHandDetected) {  
          console.log("Right Hand Lost");
          RightHandDetected = false;
          script.meshParentRightLeft[0].enabled = false;
        }
      } else if (index === 1) {
        if (LeftHandDetected) {
          console.log("Left Hand Lost");
          LeftHandDetected = false;
          script.meshParentRightLeft[1].enabled = false;
        }
      }


  });
}

function Stop() {}

//___________________________Functions__________________________//
