defmodule CloudflareStream.TusClient.Post do
  @moduledoc false
  alias CloudflareStream.TusClient.Utils

  require Logger

  def request(url, path, headers \\ [], opts \\ []) do
    path
    |> get_filesize()
    |> do_request(url, headers, opts)
  end

  defp do_request({:ok, size}, url, headers, opts) do
    hdrs =
      [{"upload-length", to_string(size)}]
      |> Utils.add_version_hdr()
      |> add_custom_headers(headers)
      |> Enum.uniq()
      |> add_metadata(opts)

    url
    |> HTTPoison.post("", hdrs, Utils.httpoison_opts([], opts))
    |> parse()
  end

  defp do_request(res, _url, _headers, _opts) do
    res
  end

  defp parse({:ok, %{status_code: 201} = resp}) do
    resp
    |> process()
  end

  defp parse({:ok, %{status_code: 413}}) do
    {:error, :too_large}
  end

  defp parse({:ok, resp}) do
    Logger.error("POST response not handled: #{inspect(resp)}")
    {:error, :generic}
  end

  defp parse({:error, err}) do
    Logger.error("POST request failed: #{inspect(err)}")
    {:error, :transport}
  end

  defp process(%{headers: []}), do: {:error, :not_supported}

  defp process(%{headers: headers}) do
    case get_location(headers) do
      {:ok, location} -> {:ok, %{location: location}}
      _ -> {:error, :location}
    end
  end

  defp get_location(headers) do
    case Utils.get_header(headers, "location") do
      v when is_binary(v) -> {:ok, v}
      _ -> {:error, :location}
    end
  end

  defp get_filesize(path) do
    case File.stat(path) do
      {:ok, %{size: size}} -> {:ok, size}
      _ -> {:error, :file_error}
    end
  end

  defp add_metadata(headers, opts) do
    case Keyword.get(opts, :metadata) do
      md when is_map(md) ->
        new_md = cleanup_metadata(md)

        new_md
        |> Enum.empty?()
        |> case do
          true ->
            headers

          false ->
            headers ++ [{"upload-metadata", encode_metadata(new_md)}]
        end

      _ ->
        headers
    end
  end

  defp cleanup_metadata(md) do
    md
    |> Enum.map(fn {k, v} ->
      {"#{k}", v}
    end)
    |> Enum.filter(fn {k, _v} ->
      case k =~ ~r/^[a-z|A-Z|0-9|_|-|\.]+$/ do
        true ->
          true

        false ->
          Logger.warn("Discarding invalid key #{k}")
          false
      end
    end)
    |> Map.new()
  end

  defp encode_metadata(md) do
    md
    |> Enum.map(fn {k, v} ->
      value = v |> to_string |> Base.encode64()
      "#{k} #{value}"
    end)
    |> Enum.join(",")
  end

  defp add_custom_headers(hdrs1, hdrs2) do
    hdrs1 ++ hdrs2
  end
end
