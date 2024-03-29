import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:liquid/models/Venue.dart';
import 'package:liquid/pages/venue_detail_page/venue_detail_page.dart';
import 'package:liquid/services/location_helper.dart';

import 'package:location/location.dart';

class FBVenuesSlider extends StatelessWidget {
  FBVenuesSlider({Key key, this.location}) : super(key: key);
  final LocationData location;
  final databaseReference = FirebaseDatabase.instance.reference().child("Venue");


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: databaseReference.onValue,
        builder: (context, snap) {

          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            DataSnapshot snapshot = snap.data.snapshot;
            List item = [];

            snapshot.value.forEach((key, value) {
              if (key != null && value != null) {
                var distance = LocationHelper.shared.calculateDistance(location == null ? 0 : location.latitude, location == null ? 0 : location.longitude, double.parse(value["latitude"]), double.parse(value["longitude"]));
                value["distance"] = distance;
                if (value["category"] != null && value["category"]["id"]  == 1 && value["isActive"] != null && value["isActive"] == true) {
                  item.add(value);
                }
              }
            });

            item.sort((a, b) => a["distance"] > b["distance"] ? 1 : -1);

            return snap.data.snapshot.value == null
                ? SizedBox()
                : Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: item.length > 10 ? 10 : item.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  //width: MediaQuery.of(context).size.width * 0.6,
                                  child: Padding(
                                padding: EdgeInsets.fromLTRB(3.0, 2, 3, 2),
                                child: InkWell(
                                  child: Container(
                                    child: Center(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                                child: new Icon(Icons.error)),
                                        imageUrl: item[index]["mainImage"] ?? "",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VenueDetailPage(venue: Venue.fromJson(item[index]))));
                                  },
                                ),
                              ));
                            })));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }


}
