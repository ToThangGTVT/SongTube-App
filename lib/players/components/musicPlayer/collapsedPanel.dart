// Dart
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';

// Internal
import 'package:songtube/players/service/playerService.dart';
import 'package:songtube/players/components/musicPlayer/ui/marqueeWidget.dart';

// Packages
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:songtube/players/service/screenStateStream.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:rxdart/rxdart.dart';
import 'package:palette_generator/palette_generator.dart';

class CollapsedPanel extends StatelessWidget {
  final double borderRadius;
  final PaletteGenerator paletteColor;
  CollapsedPanel({
    this.borderRadius, this.paletteColor
  });
  //ignore: close_sinks
  final BehaviorSubject<double> _dragPositionSubject =
    BehaviorSubject.seeded(null);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight * 1.15,
      color: this.paletteColor.darkMutedColor != null ? this.paletteColor.darkMutedColor.color : Colors.redAccent,
      child: Row(
        children: [
          // Song AlbumArt & Title and Author
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(this.borderRadius),
                    child: FadeInImage(
                      height: 50,
                      width: 50,
                      fadeInDuration: Duration(milliseconds: 400),
                      placeholder: MemoryImage(kTransparentImage),
                      image: FileImage(File(AudioService.currentMediaItem.extras["artwork"])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarqueeWidget(
                          animationDuration: Duration(seconds: 8),
                          backDuration: Duration(seconds: 3),
                          pauseDuration: Duration(seconds: 2),
                          direction: Axis.horizontal,
                          child: Text(
                            "${AudioService.currentMediaItem.title}",
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: this.paletteColor.darkMutedColor != null ? this.paletteColor.darkMutedColor.bodyTextColor : Colors.black
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "${AudioService.currentMediaItem.artist}",
                          style: TextStyle(
                            fontFamily: 'Product Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: this.paletteColor.darkMutedColor != null ? this.paletteColor.darkMutedColor.titleTextColor : Colors.black
                          ),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          // Play/Pause
          SizedBox(width: 8),
          StreamBuilder<ScreenState>(
            stream: screenStateStream,
            builder: (context, snapshot) {
              final screenState = snapshot.data;
              final state = screenState?.playbackState;
              final playing = state?.playing ?? false;
              return Stack(
                alignment: Alignment.center,
                children: [
                  StreamBuilder(
                    stream: Rx.combineLatest2<double, double, double>(
                      _dragPositionSubject.stream,
                      Stream.periodic(Duration(milliseconds: 1000)),
                      (dragPosition, _) => dragPosition),
                    builder: (context, snapshot) {
                      Duration position = state?.currentPosition ?? Duration.zero;
                      Duration duration = AudioService.currentMediaItem?.duration ?? Duration.zero;
                      return CircularProgressIndicator(
                        strokeWidth: 3,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
                        value: (position.inMilliseconds/duration.inMilliseconds),
                      );
                    }
                  ),
                  IconButton(
                    icon: playing
                      ? Icon(MdiIcons.pause, size: 22)
                      : Icon(MdiIcons.play, size: 22),
                    onPressed: playing
                      ? () => AudioService.pause()
                      : () => AudioService.play(),
                  ),
                ],
              );
            }
          ),
          SizedBox(width: 16)
        ],
      ),
    );
  }
}