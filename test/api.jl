function fresh_data()
    t1 = scatter(;y=[1, 2, 3])
    t2 = scatter(;y=[10, 20, 30])
    t3 = scatter(;y=[100, 200, 300])
    l = Layout(;title="Foo")
    p = Plot([copy(t1), copy(t2), copy(t3)], copy(l))
    t1, t2, t3, l, p
end

@testset "Test api methods on Plot" begin

    @testset "test _update_fields" begin
        t1, t2, t3, l, p = fresh_data()
        # test dict version
        for obj in [t1, l]
            o = copy(obj)
            PlotlyJS._update_fields(o, Dict{Symbol,Any}(:foo=>"Bar"))
            @test o["foo"] == "Bar"
            # kwarg version
            PlotlyJS._update_fields(o; foo="Foo")
            @test o["foo"] == "Foo"

            # dict + kwarg version
            PlotlyJS._update_fields(o, Dict{Symbol,Any}(:foo=>"Fuzzy");
                                    fuzzy_wuzzy="?")
            @test o["foo"] == "Fuzzy"
            @test o["fuzzy.wuzzy"] == "?"
        end
    end

    @testset "test relayout!" begin
        t1, t2, t3, l, p = fresh_data()
        # test on plot object
        relayout!(p, Dict{Symbol,Any}(:title=>"Fuzzy"); xaxis_title="wuzzy")
        @test p.layout["title"] == "Fuzzy"
        @test p.layout["xaxis.title"] == "wuzzy"

        # test on layout object
        relayout!(l, Dict{Symbol,Any}(:title=>"Fuzzy"); xaxis_title="wuzzy")
        @test l["title"] == "Fuzzy"
        @test l["xaxis.title"] == "wuzzy"
    end

    @testset "test restyle!" begin
        t1, t2, t3, l, p = fresh_data()
        # test on trace object
        restyle!(t1, Dict{Symbol,Any}(:opacity=>0.4); marker_color="red")
        @test t1["opacity"] == 0.4
        @test t1["marker.color"] == "red"

        # test for single trace in plot
        restyle!(p, 2, Dict{Symbol,Any}(:opacity=>0.4); marker_color="red")
        @test p.data[2]["opacity"] == 0.4
        @test p.data[2]["marker.color"] == "red"

        # test for multiple trace in plot
        restyle!(p, [1, 3], Dict{Symbol,Any}(:opacity=>0.9); marker_color="blue")
        @test p.data[1]["opacity"] == 0.9
        @test p.data[1]["marker.color"] == "blue"
        @test p.data[3]["opacity"] == 0.9
        @test p.data[3]["marker.color"] == "blue"

        # test for all traces in plot
        restyle!(p, 1:3, Dict{Symbol,Any}(:opacity=>0.42); marker_color="white")
        for i in 1:3
            @test p.data[i]["opacity"] == 0.42
            @test p.data[i]["marker.color"] == "white"
        end
    end

    @testset "test addtraces!" begin
        t1, t2, t3, l, p = fresh_data()
        p2 = Plot()

        # test add one trace to end
        addtraces!(p2, t1)
        @test length(p2.data) == 1
        @test p2.data[1] == t1

        # test add two traces to end
        addtraces!(p2, t2, t3)
        @test length(p2.data) == 3
        @test p2.data[2] == t2
        @test p2.data[3] == t3

        # test add one trace middle
        t4 = scatter()
        addtraces!(p2, 2, t4)
        @test length(p2.data) == 4
        @test p2.data[1] == t1
        @test p2.data[2] == t4
        @test p2.data[3] == t2
        @test p2.data[4] == t3

        # test add multiple trace middle
        t5 = scatter()
        t6 = scatter()
        addtraces!(p2, 2, t5, t6)
        @test length(p2.data) == 6
        @test p2.data[1] == t1
        @test p2.data[2] == t5
        @test p2.data[3] == t6
        @test p2.data[4] == t4
        @test p2.data[5] == t2
        @test p2.data[6] == t3
    end

    @testset "test deletetraces!" begin
        t1, t2, t3, l, p = fresh_data()

        # test delete one trace
        deletetraces!(p, 2)
        @test length(p.data) == 2
        @test p.data[1]["y"] == t1["y"]
        @test p.data[2]["y"] == t3["y"]

        # test delete multiple traces
        deletetraces!(p, 1, 2)
        @test length(p.data) == 0
    end

    @testset "test movetraces!" begin
        t1, t2, t3, l, p = fresh_data()

        # test move one trace to end
        movetraces!(p, 2)  # now 1 3 2
        @test p.data[1]["y"] == t1["y"]
        @test p.data[2]["y"] == t3["y"]
        @test p.data[3]["y"] == t2["y"]

        # test move two traces to end
        movetraces!(p, 1, 2) # now 2 1 3
        @test p.data[1]["y"] == t2["y"]
        @test p.data[2]["y"] == t1["y"]
        @test p.data[3]["y"] == t3["y"]

        # test move from/to
        movetraces!(p, [1, 3], [2, 1])  # 213 -> 123 -> 312
        @test p.data[1]["y"] == t3["y"]
        @test p.data[2]["y"] == t1["y"]
        @test p.data[3]["y"] == t2["y"]
    end
end
