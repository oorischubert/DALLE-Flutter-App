import 'package:flutter/material.dart';
import 'decor.dart';
import 'controller.dart';

//Image editor using openai's image generation model that creates images
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String prompt = "";
  String imageUrl = "";
  bool imageLoaded = false;

  void setImage({required String text}) {
    if (prompt != "") {
      setState(() {
        imageLoaded = false;
      });
      //get image url from api and load it into the image widget
      //print("generating image with prompt: $text"); //debug
      Controller.getApiRequest(prompt: text).then((value) {
        if (value == "error") {
          Decor.notification(
              text: "Error generating image, please try again later",
              context: context);
          return;
        }
        setState(() {
          imageUrl = value;
          imageLoaded = true;
        });
      });
    } else {
      Decor.notification(text: "Please input a prompt!", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Generator'),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Transform.scale(
                  scale: 1.5,
                  child: IconButton(
                      onPressed: () {
                        //regenerate image with prompt
                        if (imageLoaded) {
                          setImage(text: prompt);
                        }
                      },
                      icon: const Icon(Icons.refresh))))
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        //load generated image url into image in widget if image isnt available yet show a loading image
        const Spacer(),
        if (imageLoaded)
          GestureDetector(
              onDoubleTap: () async {
                bool download = await Decor.verifyPopUp(
                    context: context, titleText: "Download Image?");
                if (download) {
                Controller.download(url: imageUrl, context: context);
              }
              },
              child: InteractiveViewer(
                  panEnabled: false,
                  minScale: 1,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(0),
                  child: Image.network(
                    imageUrl,
                    height: 400,
                    width: 400,
                  )))
        else
          SizedBox(
              height: 400,
              width: 400,
              child: Transform.scale(
                  scale: 0.5, child: const CircularProgressIndicator())),
        //text input
        const Spacer(),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFormField(
              initialValue: "",
              decoration: InputDecoration(
                labelText: 'Image Prompt:',
                enabledBorder: Decor.inputformdeco(),
                focusedBorder: Decor.inputformdeco(),
              ),
              onChanged: (value) {
                prompt = value.trim();
              },
              onFieldSubmitted: (value) {
                Decor.doubleHaptics();
                //generate image
                setImage(text: value);
              },
            )),
        const Spacer(),
        const Spacer()
      ]),
    );
  }
}
