defmodule CloudflareStreamTest do 
  use ExUnit.Case

  describe "Parse metadata" do 
    @metadata """
    #EXTM3U
    #EXT-X-VERSION:6
    #EXT-X-INDEPENDENT-SEGMENTS
    #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="group_audio",NAME="eng",LANGUAGE="en",DEFAULT=YES,AUTOSELECT=YES,URI="stream_tf1bea3e54501931464e543bb005e9d0d_r15218387.m3u8"
    #EXT-X-STREAM-INF:RESOLUTION=1280x720,CODECS="avc1.4d401f,mp4a.40.2",BANDWIDTH=3728000,FRAME-RATE=30.000,AUDIO="group_audio"
    stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218383.m3u8
    #EXT-X-STREAM-INF:RESOLUTION=1920x1080,CODECS="avc1.4d4028,mp4a.40.2",BANDWIDTH=5328000,FRAME-RATE=30.000,AUDIO="group_audio"
    stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218385.m3u8
    #EXT-X-STREAM-INF:RESOLUTION=854x480,CODECS="avc1.4d401f,mp4a.40.2",BANDWIDTH=1928000,FRAME-RATE=30.000,AUDIO="group_audio"
    stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218382.m3u8
    #EXT-X-STREAM-INF:RESOLUTION=640x360,CODECS="avc1.4d401e,mp4a.40.2",BANDWIDTH=928000,FRAME-RATE=30.000,AUDIO="group_audio"
    stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218381.m3u8
    #EXT-X-STREAM-INF:RESOLUTION=426x240,CODECS="avc1.42c015,mp4a.40.2",BANDWIDTH=528000,FRAME-RATE=30.000,AUDIO="group_audio"
    stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218380.m3u8
    """
    @expected %{
      extension: "M3U",
      media: %{
        autoselect: true,
        default: true,
        group_id: "group_audio",
        language: "en",
        name: "eng",
        type: "AUDIO",
        uri: "stream_tf1bea3e54501931464e543bb005e9d0d_r15218387.m3u8"
      },
      tracks: [
        %{
          audio: "group_audio",
          bandwidth: 3728000,
          codecs: ["avc1.4d401f", "mp4a.40.2"],
          frame_rate: "30.000",
          resolution: "1280x720",
          uri: "stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218383.m3u8"
        },
        %{
          audio: "group_audio",
          bandwidth: 5328000,
          codecs: ["avc1.4d4028", "mp4a.40.2"],
          frame_rate: "30.000",
          resolution: "1920x1080",
          uri: "stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218385.m3u8"
        },
        %{
          audio: "group_audio",
          bandwidth: 1928000,
          codecs: ["avc1.4d401f", "mp4a.40.2"],
          frame_rate: "30.000",
          resolution: "854x480",
          uri: "stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218382.m3u8"
        },
        %{
          audio: "group_audio",
          bandwidth: 928000,
          codecs: ["avc1.4d401e", "mp4a.40.2"],
          frame_rate: "30.000",
          resolution: "640x360",
          uri: "stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218381.m3u8"
        },
        %{
          audio: "group_audio",
          bandwidth: 528000,
          codecs: ["avc1.42c015", "mp4a.40.2"],
          frame_rate: "30.000",
          resolution: "426x240",
          uri: "stream_ta2d3c5d56a9f8537daa3b2b7ddabd5b0_r15218380.m3u8"
        }
      ],
      version: "6"
    }
    test "Should parse metadata successfully" do 
      assert @expected == CloudflareStream.parse_metadata(@metadata, :m3u)
    end
  end
end