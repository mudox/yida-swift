//
//  MetaInspector.swift
//  MediaPlayground
//
//  Created by Mudox on 8/9/16.
//  Copyright © 2016 Mudox. All rights reserved.
//

import Foundation
import AVFoundation

class MetadataInspector {
	var rootPath: String

	let fm = FileManager.default
	var output = ""

	init(path: String) {
		rootPath = path;
	}

	func append(_ text: String) {
		output.append(text + "\n")
	}

	func main() {
		guard fm.fileExists(atPath: rootPath) else {
			print("root path \(rootPath) not exists, quit ...")
			return
		}

		let subPaths = fm.subpaths(atPath: rootPath)?.filter {
			$0.hasSuffix(".mp3")
		}

		guard var mp3Paths = subPaths else {
			print("no mp3 files found under path \(rootPath)")
			return
		}

		mp3Paths = mp3Paths.map { trail -> String in
			let path = rootPath as NSString
			return path.appendingPathComponent(trail)
		}

		var keys = Set<String>()
		var i = 0
		for path in mp3Paths {
			append("\n------")
			append(path)

			guard fm.fileExists(atPath: path) else {
				print("\t NOT exists ...")
				return;
			}

			let mp3 = AVURLAsset(url: URL(fileURLWithPath: path))
			let seconds = Int(CMTimeGetSeconds(mp3.duration))
			append("\tduration: \(seconds / 60)m \(seconds % 60)s")
			append("\tcontains metadata formats: \(mp3.availableMetadataFormats)")
			append("\tmetadata item count: \(mp3.metadata.count)")

			for item in AVMetadataItem.metadataItems(from: mp3.metadata, withKey: nil, keySpace: AVMetadataKeySpaceCommon) {
				keys.insert(item.commonKey!)
				var commonKey = item.commonKey ?? ""
				if commonKey.characters.count < 20 {
					commonKey = String(repeating: " ", count: 20 - commonKey.characters.count) + commonKey
				}
				append("\(commonKey): \(item.identifier ?? "nil id")-" +
						"\(item.key!) (\(item.keySpace!)) " +
						"of type: \(item.dataType ?? "unspecified")"
				)
			}

			var info = (title: "", artist: "", album: "", artwork: false)
			for item in AVMetadataItem.metadataItems(from: mp3.metadata, withKey: nil, keySpace: AVMetadataKeySpaceCommon) {
				switch item.commonKey! {
				case AVMetadataCommonKeyTitle:
					info.title = item.stringValue ?? ""
				case AVMetadataCommonKeyArtist:
					info.artist = item.stringValue ?? ""
				case AVMetadataCommonKeyAlbumName:
					info.album = item.stringValue ?? ""
				case AVMetadataCommonKeyArtwork:
					let dumpPath = "/tmp/artworks/\(i).png"

					switch item.value {
					case let data as Data:
						print("dump an artwork data to \(dumpPath) ...")
						try? data.write(to: URL(fileURLWithPath: dumpPath), options: [.atomic])
						i += 1
					case let dict as NSDictionary:
						print("dump an artwork data in dictionary to \(dumpPath) ...")
						if let data = dict["data"] {
							_ = (data as AnyObject).write(toFile: dumpPath, atomically: true)
							i += 1
						} else {
							print("*** failed to extract image data from NSDictionary")
						}
					default:
						print("*** failed to retreive artowrk data")
					}
					info.artwork = true

				default:
					break;
				}

			} // metadata iteration

			append("\t\t******")
			append("\t\t《\(info.title)》\n\t\t\tin: \(info.album)\n\t\t\tfrom: \(info.artist)")
			if info.artwork {
				append("\t\t\thas artwork")
			} else {
				append("\t\t\tno artwork attached")
			}
		} // file iteration

		print(keys)
		try! output.write(toFile: "/tmp/metadata", atomically: true, encoding: String.Encoding.utf8)
	}
}
