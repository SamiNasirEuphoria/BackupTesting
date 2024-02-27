using UnityEditor;
using UnityEngine;

[CustomEditor (typeof(SC_HDRLEV))]
public class SC_HDRLEV_UI : Editor {	
	//var serObj : SerializedObject;
    SerializedObject serObj;
    private SC_HDRLEV EV;
    private float camEV;
 
    void OnEnable()
    {
        serObj = new SerializedObject (target);
        //camEV = 0.0f;
        EV = (SC_HDRLEV)target;
        //camEV = Mathf.Log(0.5f,EV.ExposureValue);
        //camEV = Mathf.Log(0.5f,serObj.FindProperty ("ExposureValue"));
        //camEV = serObj.FindProperty ("ExposureValue");
        camEV = EV.ExposureValue;
    }

	public override void OnInspectorGUI () {
        serObj.Update ();
        //Camera EV
        camEV = EditorGUILayout.Slider("-EV: ", camEV, 0.0f, 8.0f);
        //Convert from Camera EV to Power EV  
        EV.ExposureValue = Mathf.Abs(camEV);

        //Power EV  
        //EV.ExposureValue = EditorGUILayout.Slider("EV", EV.ExposureValue, 0.0f, 1.0f);

   		//EditorGUILayout.Separator ();	
        if(GUI.changed)	{
            EditorUtility.SetDirty (target); // Update Atom_HDRLEV script
        }
		
    	
    	serObj.ApplyModifiedProperties();

    }
}