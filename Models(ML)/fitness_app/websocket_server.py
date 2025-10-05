# websocket_server.py

import asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect

# This is our new, simplified FastAPI app
app = FastAPI()

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    This endpoint handles the WebSocket connection.
    It listens for messages from a client, maintains a counter for that client,
    and sends the updated count back after each message.
    """
    print("Client connected...")
    await websocket.accept()
    
    # Each client gets their own counter, starting at 0.
    rep_count = 0
    
    try:
        while True:
            # Wait for a message from the Flutter app
            data = await websocket.receive_text()
            
            # If the app tells us a rep was completed, increment the counter
            if data == "rep_completed":
                rep_count += 1
                print(f"Rep counted. Total: {rep_count}")
                
                # Send the new count back to the Flutter app
                await websocket.send_text(f"{rep_count}")

    except WebSocketDisconnect:
        print("Client disconnected.")

@app.get("/health")
def health():
    return {"status": "ok"}

# To run this server:
# uvicorn websocket_server:app --host 0.0.0.0 --port 8000