using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetupSSSMaterial : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.GetComponent<Renderer>().material.SetVector("vLightPosition", gameObject.transform.position);
    }
}
