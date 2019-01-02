
# Microsoft Azure Face API iOS Demo

This demo app demonstrates how to integrate Microsoft Azure Face REST API on iOS. It utilizes in particularly the [Face - Detect](https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236) and [Face - Find Similar](https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395237) endpoints. It showcases how to search/filter photos based on a selected face.

![Demo](https://github.com/acotilla91/Microsoft-Azure-iOS-Facial-Recognition-Demo/blob/master/avengers_demo.gif)

## How to enable Microsoft Azure Face API
In order to use Microsoft Azure Face API, we need to obtain a Face API subscription key.

1.  Go to the Cognitive Services signup  [page](https://azure.microsoft.com/en-us/try/cognitive-services/?api=face-api).
2.  Select “Get API Key” for the Face service.
3.  Signup for a “Free Azure account” (not the “Guest”, as that one has very low limits). Is really free, and you’ll get $200 in credits (which is a LOT).
4.  Follow all the steps to create a new account (or sign in with your existing Microsoft account).
5.  Go to the  [Azure portal](https://portal.azure.com/).
6.  Search for “Cognitive Services” in the search bar at top.
7.  Select “Create cognitive Services”.
8.  Search for “Face” in the filtering bar that shows up.
9.  Select “Face” and hit “Create”.
10.  Set a name, location, pricing tier and select “Create new” resource group.
11. Go to All resources > FaceService > Keys and copy and save “KEY 1” (we’ll use it later).
12. Go to All resources > FaceService > Pricing tier and make sure the “Standard” tier is selected.

## Running the app
1.  Clone this repo 
	```
	$ git clone https://github.com/acotilla91/Microsoft-Azure-iOS-Facial-Recognition-Demo.git
	```
2.  Open project in Xcode.
3.  Go to the `AzureFaceRecognition` class and replace `<API-KEY>` with the actual API key that was obtained from the account setup steps above.
4.  Run the app.
5.  Select any of the avatars.
6.  The collection view should reload its content and display only photos of that person.
