// 18-10  Dart Gestion Erreur avec ??
// Apres ??  mettre la Valeur si Numm
// dateSelected = dateSelection  ?? dateSelectedPrev;

// Traitement des Infos recues de brocabrac
// On reçoit une URL vers brocabrac avec
// Une date
// des départements max 4
// catégorie Vg (vode grnier ) et Br ( brocnte)
// On renvoie lrs infos dans une liste d'objets brocabarc

import 'dart:convert';

import 'package:cobrac/pmltools.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

List lecture = [];

class NetworkHelper {
  NetworkHelper();

  Future<List> getDataBrocabrac(Uri myUrl, fullMaster) async {
    final response = await http.get(myUrl);
    //print("myUrl  = " + myUrl.toString());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response    then parse the JSON.
      var stepOne = parse(response.body);

      List<dom.Element> nbexpo = stepOne.getElementsByClassName("dots");
      List nbExposants = [];
      for (dom.Element tata in nbexpo) {
        if (tata.attributes.containsKey("title") == false) {
        } else {
          var ff = tata.attributes["title"];
          nbExposants.add(ff);
        }
      }
      List<dom.Element> elocucu = stepOne.getElementsByTagName("script");
      int j = 0;

      for (dom.Element entryBrocabrac in elocucu) {
        if (entryBrocabrac.attributes.containsKey("type") == false) {
        } else {
          var whatType = entryBrocabrac.attributes["type"];
          //if (whatType == "h3") {print (" I  ya un <h3>");}
          if (whatType == "application/ld+json") {
            if (entryBrocabrac.hasChildNodes()) {
              var sss = entryBrocabrac.nodes[0];
              var lookJson = sss.text;
              Map<String, dynamic> user = jsonDecode(lookJson);

              if (user["@type"] == "Event") {
                j++;

                String _brocType = "";
                if (user["@type"] != null) _brocType = user["@type"];
                String _brocLocality = "";
                if (user["location"]["address"]["addressLocality"] != null)
                  _brocLocality =
                      user["location"]["address"]["addressLocality"];
                String _brocPostal = "";
                if (user["location"]["address"]["postalCode"] != null)
                  _brocPostal = user["location"]["address"]["postalCode"];
                String _brocStreet = "";
                if (user["location"]["address"]["streetAddress"] != null)
                  _brocStreet = user["location"]["address"]["streetAddress"];
                double _brocLatitude = -20;
                if (user["location"]["geo"]["latitude"] != null)
                  _brocLatitude = user["location"]["geo"]["latitude"];
                double _brocLongitude = -20;
                if (user["location"]["geo"]["longitude"] != null)
                  _brocLongitude = user["location"]["geo"]["longitude"];
                String _brocEventStatus = "";
                if (user["eventStatus"] != null)
                  _brocEventStatus = user["eventStatus"];
                String _brocOrganizer = "Unknown";
                if (user.containsKey("organizer") == true)
                  _brocOrganizer = user["organizer"]["name"] ?? "Unknown";

                String _brocStartDate = "";
                if (user["startDate"] != null)
                  _brocStartDate = user["startDate"];
                //
                String _brocEndDate = "";
                if (user["startDate"] != null) _brocEndDate = user["endDate"];
                //
                String _brocDescription = "";
                if (user["description"] != null) {
                  _brocDescription = user["description"];

                  print(_brocLocality +
                      " -->" +
                      _brocDescription.length.toString());
                }
                String _brocNbExposants = "";
                if (nbExposants[j - 1] != null)
                  _brocNbExposants = nbExposants[j - 1];
                //
                if (_brocEventStatus != null) {
                  if (_brocEventStatus.indexOf('ancelled') != -1) {
                    _brocEventStatus = 'KO';
                  } else //  Cancelled ?
                  {
                    _brocEventStatus = 'OK';
                  }
                }
                // _Brocabrac ne vit que quelques lignes
                // Pas en lowerCamelCase mais commencant par un unsescore pour
                // signifier le temporaire
                // Instance créée pour remplir full master

                Brocabrac _Brocabrac = Brocabrac(
                    _brocType,
                    _brocLocality,
                    _brocPostal,
                    _brocStreet,
                    _brocLatitude,
                    _brocLongitude,
                    _brocEventStatus,
                    _brocOrganizer,
                    _brocStartDate,
                    _brocEndDate,
                    _brocDescription,
                    _brocNbExposants);
                _Brocabrac.debugBrocLocality();
                fullMaster.add(_Brocabrac);
              } // Event

            } //application/ld+json
          }
        }
      }
      return (fullMaster);
    } else {
      //print(response.body);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load http');
    }
  }
}
