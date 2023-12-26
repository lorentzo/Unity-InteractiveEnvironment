using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class GamePlay : MonoBehaviour
{
    GameObject selectedGameObject;
    GameObject player;
    float gameObjectMovementSensitivity = 0.5f;
    float gameObjectScaleSensitivity = 0.5f;
    string[] nonSelectableObjects;
    enum GameObjectInteractionStates 
    {
        Moving,
        Scaling
    }
    GameObjectInteractionStates gameObjectInteractionState;
    enum InteractionStates
    {
        Player,
        InteractiveElements
    }
    InteractionStates interactionState;
    float playerTorque = 25.0f;
    float playerForce = 50.0f;
    Rigidbody playerRigidbody;

    // Start is called before the first frame update
    void Start()
    {
        interactionState = InteractionStates.Player;
        player = GameObject.FindWithTag("Player");
        playerRigidbody = player.GetComponent<Rigidbody>();
        selectedGameObject = null;
        gameObjectInteractionState = GameObjectInteractionStates.Scaling;
        nonSelectableObjects = new string[] {"Player", "WallLeft", "WallRight", "WallFront", "WallBot", "WallTop", "WallBack"};
        Debug.Log("Interaction state Player.");
    }

    void FixedUpdate()
    {
        if (interactionState == InteractionStates.Player)
        {
            if (Input.GetKeyDown("w"))
            {
                Debug.Log("Moving player using key w.");
                playerRigidbody.AddTorque(playerTorque, 0.0f, 0.0f); 
            }
            if (Input.GetKeyDown("s"))
            {
                Debug.Log("Moving player using key s.");
                playerRigidbody.AddTorque(-playerTorque, 0.0f, 0.0f); 
            }
            if (Input.GetKeyDown("d"))
            {
                Debug.Log("Moving player using key d.");
                playerRigidbody.AddTorque(0.0f, 0.0f, -playerTorque); 
            }
            if (Input.GetKeyDown("a"))
            {
                Debug.Log("Moving player using key a.");
                playerRigidbody.AddTorque(0.0f, 0.0f, playerTorque); 
            }
            if (Input.GetKeyDown("space"))
            {
                Debug.Log("Moving player using key space.");
                playerRigidbody.AddForce(0.0f, playerForce, 0.0f); 
            }
        }
    }

    // Update is called once per frame
    void Update()
    {

        // Selecting interaction state.
        if (Input.GetKeyDown("tab"))
        {
            selectedGameObject = null;
            if(interactionState == InteractionStates.Player)
            {
                interactionState = InteractionStates.InteractiveElements;
                Debug.Log("Changing interaction state to Interactive Elements.");
            }
            else
            {
                interactionState = InteractionStates.Player;
                Debug.Log("Changing interaction state to Player.");
            }
        }

        // Selecting interactive element.
        if (Input.GetMouseButtonDown(0) && interactionState == InteractionStates.InteractiveElements)
        {
            selectGameObjectByRaycast();
            gameObjectInteractionState = GameObjectInteractionStates.Scaling;
        }

        // Deselecting game object.
        if (Input.GetKeyDown("escape") && interactionState == InteractionStates.InteractiveElements)
        {
            Debug.Log("Deselecting: " + selectedGameObject.name);
            selectedGameObject = null;
        }

        // Changing Game object interaction state.
        if (Input.GetKeyDown("space") && interactionState == InteractionStates.InteractiveElements)
        {
            if (gameObjectInteractionState == GameObjectInteractionStates.Moving)
            {
                gameObjectInteractionState = GameObjectInteractionStates.Scaling;
            }
            else
            {
                gameObjectInteractionState = GameObjectInteractionStates.Moving;
            }
        }

        // Scaling game object.
        if (selectedGameObject && (gameObjectInteractionState == GameObjectInteractionStates.Scaling) && (interactionState == InteractionStates.InteractiveElements))
        {
            Vector3 gameObjectScale = selectedGameObject.transform.localScale;
            if (Input.GetKey("w"))
            {
                gameObjectScale += Vector3.forward * gameObjectScaleSensitivity;
                Debug.Log("Scaling: " + selectedGameObject + " with w");
            }
            if (Input.GetKey("s"))
            {
                gameObjectScale += Vector3.back * gameObjectScaleSensitivity;
                Debug.Log("Scaling: " + selectedGameObject + " with s");
            }
            if (Input.GetKey("d"))
            {
                gameObjectScale += Vector3.right * gameObjectScaleSensitivity;
                Debug.Log("Scaling: " + selectedGameObject + " with d");
            }
            if (Input.GetKey("a"))
            {
                gameObjectScale += Vector3.left * gameObjectScaleSensitivity;
                Debug.Log("Scaling: " + selectedGameObject + " with a");
            }
            if (Input.GetKey("e"))
            {
                gameObjectScale += Vector3.up * gameObjectScaleSensitivity;
                Debug.Log("Scaling: " + selectedGameObject + " with e");
            }
            if (Input.GetKey("q"))
            {
                gameObjectScale += Vector3.down * gameObjectScaleSensitivity;
                Debug.Log("Scaling: " + selectedGameObject + " with q");
            }
            if (gameObjectScale.x > 0.0f && gameObjectScale.y > 0.0f && gameObjectScale.z > 0.0f)
            {
                selectedGameObject.transform.localScale = gameObjectScale;
            }
        }

        // Moving game object.
        if (selectedGameObject && (gameObjectInteractionState == GameObjectInteractionStates.Moving) && interactionState == InteractionStates.InteractiveElements)
        {
            if (Input.GetAxis("Mouse X") > 0.0f)
            {
                selectedGameObject.transform.localPosition += Vector3.right * gameObjectMovementSensitivity;
            }
            if (Input.GetAxis("Mouse X") < 0.0f)
            {
                selectedGameObject.transform.localPosition += Vector3.left * gameObjectMovementSensitivity;
            }
            if (Input.GetAxis("Mouse Y") > 0.0f)
            {
                selectedGameObject.transform.localPosition += Vector3.forward * gameObjectMovementSensitivity;
            }
            if (Input.GetAxis("Mouse Y") < 0.0f)
            {
                selectedGameObject.transform.localPosition += Vector3.back * gameObjectMovementSensitivity;
            }
        }
        
    }

    void selectGameObjectByRaycast()
    {
        Ray camera_ray = GetComponent<Camera>().ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        bool selectable = true;
        if (Physics.Raycast(camera_ray, out hit))
        {
            GameObject tmpSelectedGameObject = hit.transform.gameObject;
            for (int i = 0; i < nonSelectableObjects.Length; i++)
            {
                if (tmpSelectedGameObject.name.Equals(nonSelectableObjects[i]))
                {
                    selectable = false;
                }
            }
            if (selectable)
            {
                selectedGameObject = tmpSelectedGameObject;
                Debug.Log("Selecting: " + selectedGameObject.name);
            }
        }
    }

}
