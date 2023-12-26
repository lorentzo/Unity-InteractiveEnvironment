using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractiveMesh : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;

        /*
        if (Input.GetKeyDown("space"))
        {
            Debug.Log("space key was pressed");
            vertices[0] += Vector3.forward * 2.0f;
            vertices[1] += Vector3.forward * 2.0f;
            vertices[2] += Vector3.forward * 2.0f;
            vertices[3] += Vector3.forward * 2.0f;
            mesh.vertices = vertices;
            mesh.RecalculateNormals();
        }
        */
    }
}
