defmodule CloudflareStream do 
  require Logger

  @opts_keys %{
    # media
    "TYPE" => :type,
    "GROUP-ID" => :group_id,
    "NAME" => :name,
    "LANGUAGE" => :language,
    "DEFAULT" => :default,
    "AUTOSELECT" => :autoselect,
    "URI" => :uri,
    # extension 
    "EXT" => :extension,
    # track info
    "RESOLUTION" => :resolution,
    "CODECS" => :codecs,
    "BANDWIDTH" => :bandwidth,
    "FRAME-RATE" => :frame_rate,
    "AUDIO" => :audio
  }

  @opts_types %{
    codecs: :list,
    autoselect: :boolean,
    default: :boolean,
    bandwidth: :integer
  }

  @track_key :track

  @doc """

  Example usage: 
  ```
  CloudflareStream.parse_metadata(metadata, :m3u)
  ```

  Extracts all available data from M3U video metadata

  Example .m3u8 metadata:

  ```
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
  ```

  Parse result:

  ```
  %{
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
  ```
  """
  @spec parse_metadata(String.t(), :m3u) :: map()
  def parse_metadata(metadata, :m3u) do 
    split = 
      metadata 
      |> String.split("\n")
    split
    |> Enum.map(fn x -> parse_line(x, metadata) end)
    |> parse_format(split)
    |> format()
  end

  defp format(opts) do 
    opts
    |> Enum.filter(&is_map/1)
    |> collect_keys(@track_key, :tracks)
    |> Enum.reduce(%{}, fn x, acc -> 
      Map.merge(acc, x)
    end)
  end

  defp collect_keys(opts, key, put_key) do
    collected =
      opts
      |> Enum.filter(fn x -> 
        Map.get(x, key) != nil
      end)
      |> Enum.reduce(%{put_key => []}, fn x, acc -> 
        v = Map.get(x, key)
        Map.put(acc, put_key, acc[put_key] ++ [v])
      end)
    opts
    |> Enum.reject(fn x -> 
      Map.get(x, key) != nil
    end)
    |> List.insert_at(-1, collected)
  end

  defp opts_atom_key(key) do 
    @opts_keys
    |> Map.get(key, key)
  end

  defp parse_format(x, [h | _t]) when is_binary(h) do 
    format = 
      h
      |> String.split("#EXT")
      |> List.last()
    format_opts = 
      "EXT"
      |> opts_atom_key()  
      |> List.wrap()
      |> List.insert_at(1, format)
      |> List.to_tuple()
      |> List.wrap()
      |> Map.new()
      |> List.wrap()
    format_opts ++ x
  end

  defp parse_line("#EXT-X-VERSION:" <> opts, _) do 
    opts
    |> version()
  end

  defp parse_line("#EXT-X-MEDIA:" <> opts, _) do 
    opts
    |> fragment("URI")
    |> fragment("LANGUAGE")
    |> fragment("GROUP-ID")
    |> fragment("NAME")
    |> extract_opts([:media])
  end

  defp parse_line("#EXT-X-STREAM-INF:" <> opts, raw) do 
    opts
    |> uri(raw)
    |> fragment("CODECS")
    |> fragment("AUDIO")
    |> extract_opts([@track_key])
  end

  defp parse_line("stream_" <> _track_path = x, _) do 
    x
  end

  defp parse_line(x, _) do
    Logger.debug("Ignored metadata string >> #{x}")
    x
  end

  defp uri(line, raw) do 
    uri =
      raw
      |> String.split(line)
      |> List.last()
      |> String.split("\n")
      |> Enum.filter(fn x -> String.length(x) > 0 end)
      |> List.first()
    line
    |> String.replace_suffix("", "," <> "URI=#{uri}")  
  end
  
  defp fragment(line, key) do 
    fragment = 
      line
      |> String.split("#{key}=\"")
      |> List.last()
      |> String.split("\"")
      |> List.first()
    new_fragment = 
      fragment
      |> String.replace(",", ";", [])
    replace_fragment = 
      fragment
      |> String.replace_prefix("", "\"")  
      |> String.replace_suffix("", "\"")  
    line
    |> String.replace(replace_fragment, new_fragment)
  end

  defp version(version) do 
    %{version: version}
  end

  defp extract_opts(opts, path) when is_list(path) do 
    opts
    |> String.split(",")
    |> Enum.flat_map(fn x -> 
      String.split(x, "=")
    end)
    |> Enum.chunk_every(2)
    |> parse_opts(path)
  end

  defp parse_opts(opts, path) do
    opts
    |> Enum.map(&List.to_tuple/1)
    |> Enum.reduce(%{}, fn ({key, value}, acc) ->
      key = opts_atom_key(key)
      value = parse_opt_value(key, value)
      put_opts(acc, path ++ [key], value)
    end)
  end

  defp parse_opt_value(key, value) do 
    case Map.get(@opts_types, key) do 
      :list -> String.split(value, ";")
      :boolean -> bool_value(value)
      :integer -> integer_value(value)
      _ -> value
    end
  end

  defp integer_value(value) do 
    case Integer.parse(value) do
      {x, _} -> x
      _ -> value
    end
  end
  
  defp bool_value("YES"), do: true
  defp bool_value(_), do: false

  defp put_opts(opts, path, value) do 
    last = List.last(path)
    path
    |> Enum.reduce(opts, fn (x, acc) -> 
      acc = 
        case Map.get(acc, x) do
          nil when last != x -> put_in(acc, [x], %{})
          _ -> acc
        end
      case x do 
        k when k == last -> put_in(acc, path, value)
        _ -> acc
      end
    end)
  end
end