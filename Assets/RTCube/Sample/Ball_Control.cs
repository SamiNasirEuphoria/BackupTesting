using UnityEngine;
using System.Collections;

public class Ball_Control : MonoBehaviour {

    private GameObject objBall;
    public float speed = 0.01f;

	void Start ()
	{
		objBall = GameObject.Find("demo_rtref01_ball");
		objBall.SetActive(true);
		transform.position = transform.position + new Vector3(0,0,-1.69f);
	}


	void Update() {
		//objGroup.transform.Rotate( Vector3.up * ( 5.0f * Time.deltaTime ) );
		//Z aixs from 1.7 to -1.7 
		if (transform.position.z < 1.7f && transform.position.z > -1.7f){
			transform.position = transform.position + new Vector3(0,0,speed);
		}
		else{
			speed *= -1.0f;
			transform.position = transform.position + new Vector3(0,0,speed);
		}
		
	}

	void OnGUI () {

	}


}