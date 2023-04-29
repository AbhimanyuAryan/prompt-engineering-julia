### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 881ff330-e654-11ed-1715-613ce23f8fab
using OpenAI

# ╔═╡ 2a512b6c-3320-41a1-8cd5-5e8f507648da
using DotEnv

# ╔═╡ af624fca-ab64-4dfd-a444-0d25856eb938
DotEnv.config(); # ; hides the out of executed cell

# ╔═╡ 32eb5bbf-7180-4fc0-bc5f-5c593dc7eeb8
GPT_API_KEY = ENV["OPENAI_API_KEY"];

# ╔═╡ de450bf7-3009-442b-bd66-7cac8969257c
md"""
helper function¶
Throughout this course, we will use OpenAI's gpt-3.5-turbo model and the chat [completions endpoint](https://platform.openai.com/docs/guides/chat).

This helper function will make it easier to use prompts and look at the generated outputs:
"""

# ╔═╡ 295c6914-d906-4874-9d80-d5bc1c56d275
md"""
## Prompting Principles
- **Principle 1: Write clear and specific instructions**
- **Principle 2: Give the model time to “think”**

### Tactics

#### Tactic 1: Use delimiters to clearly indicate distinct parts of the input
- Delimiters can be anything like: ```, \""", `< >`, `<tag> </tag>`, `:`
"""

# ╔═╡ b071c73d-535b-49e8-a597-6c3fc6f5a4c5
function getCompletion(prompt, model="gpt-3.5-turbo")
	message = [Dict("role" => "user",
					"content"=> prompt
			  )]
	CC = create_chat(GPT_API_KEY, model, message)
	CC.response["choices"][1]["message"]["content"]
end

# ╔═╡ d3ac851c-3724-44da-91db-13d6c6330ea2
begin
	text = """
	You should express what you want a model to do by
	providing instructions that are as clear and
	specific as you can possibly make them.
	This will guide the model towards the desired output, 
	and reduce the chances of receiving irrelevant
	or incorrect responses. Don't confuse writing a 
	clear prompt with writing a short prompt.
	In many cases, longer prompts provide more clarity
	and context for the model, which can lead to
	more detailed and relevant outputs.
	"""
	
	prompt1 = "Summarize the text delimited by triple backticks into a single sentence. ```$(text)```"
	
	getCompletion(prompt1)
end

# ╔═╡ a4d2d346-5952-4f24-81d8-dd0c653f21f1
md"""
#### Tactic 2: Ask for a structured output
- JSON, HTML
"""

# ╔═╡ ad3a7b7d-617b-4e41-9406-4f40710604fc
begin
	prompt2 = """
	Generate a list of three made-up book titles along
	with their authors and genres. 
	Provide them in JSON format with the following keys: 
	book_id, title, author, genre.
	"""
	
	getCompletion(prompt2)
end

# ╔═╡ 662f63b4-9cb4-4b06-b4da-57f24eb54089
md"""
#### Tactic 3: Ask the model to check whether conditions are satisfied
"""

# ╔═╡ dcb52dc2-9cf4-4eda-a75f-80e4d52647e8
begin
	text_1 = """
	Making a cup of tea is easy! First, you need to get some
	water boiling. While that's happening,
	grab a cup and put a tea bag in it. Once the water is
	hot enough, just pour it over the tea bag.
	Let it sit for a bit so the tea can steep. After a
	few minutes, take out the tea bag. If you
	like, you can add some sugar or milk to taste.
	And that's it! You've got yourself a delicious 
	cup of tea to enjoy.
	"""
	prompt3 = """
	You will be provided with text delimited by triple quotes. 
	If it contains a sequence of instructions,
	re-write those instructions in the following format:
	
	Step 1 - ...
	Step 2 - …
	…
	Step N - …
	
	If the text does not contain a sequence of instructions,
	then simply write \"No steps provided.\"
	
	\"\"\"$(text_1)\"\"\"
	"""
	response3 = getCompletion(prompt3)
	println("Completion for Text 1:")
	println(response3)
end

# ╔═╡ df696060-56a9-4e9a-bfd3-1b791bb7ea1e
md"""
#### Tactic 4: "Few-shot" prompting
"""

# ╔═╡ 6506d27c-9a9f-4c95-879b-eab0180911f4
begin
	prompt4 = """
	Your task is to answer in a consistent style.
	
	<child>: Teach me about patience.
	
	<grandparent>: The river that carves the deepest
	valley flows from a modest spring; the
	grandest symphony originates from a single note;
	the most intricate tapestry begins with a solitary thread.
	
	<child>: Teach me about resilience.
	"""
	response4 = getCompletion(prompt4)
	print(response4)
end

# ╔═╡ b5d05d21-cf99-48b1-93f0-7b2aca2d6bae
md"""
### Principle 2: Give the model time to “think” 

#### Tactic 1: Specify the steps required to complete a task
"""

# ╔═╡ 87abd33f-4b6e-4fec-b845-e4e2908cce10
begin
	text2_1 = """
	In a charming village, siblings Jack and Jill set out on
	a quest to fetch water from a hilltop
	well. As they climbed, singing joyfully, misfortune
	struck—Jack tripped on a stone and tumbled
	down the hill, with Jill following suit.
	Though slightly battered, the pair returned home to
	comforting embraces. Despite the mishap,
	their adventurous spirits remained undimmed, and they
	continued exploring with delight.
	"""
	# example 1
	prompt2_1 = """
	Perform the following actions: 
	1 - Summarize the following text delimited by triple
	backticks with 1 sentence.
	2 - Translate the summary into French.
	3 - List each name in the French summary.
	4 - Output a json object that contains the following
	keys: french_summary, num_names.
	
	Separate your answers with line breaks.
	
	Text:
	```$(text2_1)```
	"""
	response2_1 = getCompletion(prompt2_1)
	println("Completion for prompt 2_1:")
	println(response2_1)
end

# ╔═╡ 7e8cdfb2-ff5f-4f19-b4c0-a9c35cf5b178
md"""
#### Ask for output in a specified format
"""

# ╔═╡ 20ec2251-ca2c-4aaf-b6ca-b99fefff8572
begin
	prompt2_2 = """
	Your task is to perform the following actions: 
	1 - Summarize the following text delimited by 
	  <> with 1 sentence.
	2 - Translate the summary into French.
	3 - List each name in the French summary.
	4 - Output a json object that contains the 
	  following keys: french_summary, num_names.
	
	Use the following format:
	Text: <text to summarize>
	Summary: <summary>
	Translation: <summary translation>
	Names: <list of names in Italian summary>
	Output JSON: <json with summary and num_names>
	
	Text: <$(text2_1)>
	"""
	response2_2 = getCompletion(prompt2_2)
	println("\nCompletion for prompt 2_2:")
	println(response2_2)
end

# ╔═╡ 48e45458-23d3-4f80-b73e-2f91765efd33
md"""
#### Tactic 2: Instruct the model to work out its own solution before rushing to a conclusion
"""

# ╔═╡ a0026a02-dab9-4396-9384-a0170bb843d3
begin
	prompt2_3 = """
	Determine if the student's solution is correct or not.
	
	Question:
	I'm building a solar power installation and I need
	 help working out the financials. 
	- Land costs \$100 / square foot
	- I can buy solar panels for \$250 / square foot
	- I negotiated a contract for maintenance that will cost
	me a flat \$100k per year, and an additional \$10 / square
	foot
	What is the total cost for the first year of operations 
	as a function of the number of square feet.
	
	Student's Solution:
	Let x be the size of the installation in square feet.
	Costs:
	1. Land cost: 100x
	2. Solar panel cost: 250x
	3. Maintenance cost: 100,000 + 100x
	Total cost: 100x + 250x + 100,000 + 100x = 450x + 100,000
	"""
	response2_3 = getCompletion(prompt2_3)
	print(response2_3)
end

# ╔═╡ 87e3bec7-d129-443b-afdb-2e66d541b023
md"""
#### Note that the student's solution is actually not correct.
#### We can fix this by instructing the model to work out its own solution first.
"""

# ╔═╡ 0329c7b1-c704-496b-b155-bdaf69d19b76
begin
	prompt2_4 = """
	Your task is to determine if the student's solution
	is correct or not.
	To solve the problem do the following:
	- First, work out your own solution to the problem. 
	- Then compare your solution to the student's solution
	and evaluate if the student's solution is correct or not. 
	Don't decide if the student's solution is correct until 
	you have done the problem yourself.
	
	Use the following format:
	Question:
	```
	question here
	```
	Student's solution:
	```
	student's solution here
	```
	Actual solution:
	```
	steps to work out the solution and your solution here
	```
	Is the student's solution the same as actual solution
	just calculated:
	```
	yes or no
	```
	Student grade:
	```
	correct or incorrect
	```
	
	Question:
	```
	I'm building a solar power installation and I need help
	working out the financials. 
	- Land costs \$100 / square foot
	- I can buy solar panels for \$250 / square foot
	- I negotiated a contract for maintenance that will cost
	me a flat \$100k per year, and an additional \$10 / square
	foot
	What is the total cost for the first year of operations
	as a function of the number of square feet.
	``` 
	Student's solution:
	```
	Let x be the size of the installation in square feet.
	Costs:
	1. Land cost: 100x
	2. Solar panel cost: 250x
	3. Maintenance cost: 100,000 + 100x
	Total cost: 100x + 250x + 100,000 + 100x = 450x + 100,000
	```
	Actual solution:
	"""
	response2_4 = getCompletion(prompt2_4)
	print(response2_4)
end

# ╔═╡ 0eb9c14f-60b9-4ae3-bafc-c92006c7181d
md"""
## Model Limitations: Hallucinations
- Boie is a real company, the product name is not real.
"""

# ╔═╡ e56a58f6-0341-4cd0-b69d-3e5e54470389
begin
	prompt2_5 = """
	Tell me about AeroGlide UltraSlim Smart Toothbrush by Boie
	"""
	response2_5 = getCompletion(prompt2_5)
	print(response2_5)
end

# ╔═╡ f5ce19bd-9d99-4260-b626-d9397222d2d9
md"""
## Try experimenting on your own!
"""

# ╔═╡ e380ed6b-a247-4c0c-af7a-b43b2413229a
md"""
#### A note about the backslash
- In the course, we are using a backslash `\` to make the text fit on the screen without inserting newline '\n' characters.
- GPT-3 isn't really affected whether you insert newline characters or not.  But when working with LLMs in general, you may consider whether newline characters in your prompt may affect the model's performance.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DotEnv = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
OpenAI = "e9f21f70-7185-4079-aca2-91159181367c"

[compat]
DotEnv = "~0.3.1"
OpenAI = "~0.8.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0-rc2"
manifest_format = "2.0"
project_hash = "5e6a329da2084da59759a01dbdaa5350ead6c97f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "b306df2650947e9eb100ec125ff8c65ca2053d30"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.1.1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DotEnv]]
git-tree-sha1 = "d48ae0052378d697f8caf0855c4df2c54a97e580"
uuid = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
version = "0.3.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "69182f9a2d6add3736b7a06ab6416aafdeec2196"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.8.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "SnoopPrecompile", "StructTypes", "UUIDs"]
git-tree-sha1 = "84b10656a41ef564c39d2d477d7236966d2b5683"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.12.0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenAI]]
deps = ["HTTP", "JSON3"]
git-tree-sha1 = "625c266994badbc323f96e769cc471cb9cfa7c34"
uuid = "e9f21f70-7185-4079-aca2-91159181367c"
version = "0.8.3"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "7fb975217aea8f1bb360cf1dde70bad2530622d2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6cc6366a14dbe47e5fc8f3cbe2816b1185ef5fc4"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.8+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "0b829474fed270a4b0ab07117dce9b9a2fa7581a"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.12"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"
"""

# ╔═╡ Cell order:
# ╠═881ff330-e654-11ed-1715-613ce23f8fab
# ╠═2a512b6c-3320-41a1-8cd5-5e8f507648da
# ╠═af624fca-ab64-4dfd-a444-0d25856eb938
# ╠═32eb5bbf-7180-4fc0-bc5f-5c593dc7eeb8
# ╟─de450bf7-3009-442b-bd66-7cac8969257c
# ╟─295c6914-d906-4874-9d80-d5bc1c56d275
# ╠═b071c73d-535b-49e8-a597-6c3fc6f5a4c5
# ╠═d3ac851c-3724-44da-91db-13d6c6330ea2
# ╟─a4d2d346-5952-4f24-81d8-dd0c653f21f1
# ╠═ad3a7b7d-617b-4e41-9406-4f40710604fc
# ╟─662f63b4-9cb4-4b06-b4da-57f24eb54089
# ╠═dcb52dc2-9cf4-4eda-a75f-80e4d52647e8
# ╟─df696060-56a9-4e9a-bfd3-1b791bb7ea1e
# ╠═6506d27c-9a9f-4c95-879b-eab0180911f4
# ╟─b5d05d21-cf99-48b1-93f0-7b2aca2d6bae
# ╠═87abd33f-4b6e-4fec-b845-e4e2908cce10
# ╟─7e8cdfb2-ff5f-4f19-b4c0-a9c35cf5b178
# ╠═20ec2251-ca2c-4aaf-b6ca-b99fefff8572
# ╟─48e45458-23d3-4f80-b73e-2f91765efd33
# ╠═a0026a02-dab9-4396-9384-a0170bb843d3
# ╟─87e3bec7-d129-443b-afdb-2e66d541b023
# ╠═0329c7b1-c704-496b-b155-bdaf69d19b76
# ╟─0eb9c14f-60b9-4ae3-bafc-c92006c7181d
# ╠═e56a58f6-0341-4cd0-b69d-3e5e54470389
# ╟─f5ce19bd-9d99-4260-b626-d9397222d2d9
# ╟─e380ed6b-a247-4c0c-af7a-b43b2413229a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
