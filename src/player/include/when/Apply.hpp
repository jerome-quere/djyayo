/*
 * Source :  Paul Preney http://www.preney.ca/paul/
 * Href: http://www.preney.ca/paul/archives/486
 */
#ifndef _WHEN_APPLY_HPP_
#define _WHEN_APPLY_HPP_

namespace When
{
    template <std::size_t...>
    struct indices;

    template <std::size_t N, typename Indices, typename... Types>
    struct make_indices_impl;

    template <std::size_t N,
	      std::size_t... Indices,
	      typename Type,
	      typename... Types>
    struct make_indices_impl<N, indices<Indices...>, Type, Types...> {
	typedef typename make_indices_impl<N+1, indices<Indices...,N>, Types...>::type type;
    };

    template <std::size_t N, std::size_t... Indices>
    struct make_indices_impl<N, indices<Indices...>> {
	typedef indices<Indices...> type;
    };

    template <std::size_t N, typename... Types>
    struct make_indices {
	typedef typename make_indices_impl<0, indices<>, Types...>::type type;
    };


    template <typename Indices>
    struct apply_tuple_impl;

    template <template <std::size_t...> class I, std::size_t... Indices>
    struct apply_tuple_impl<I<Indices...>> {
	template < typename Op,
		   typename... OpArgs,
		   template <typename...> class T>
	    static auto apply_tuple(Op&& op, T<OpArgs...>&& t)
	    -> typename std::result_of<Op(OpArgs...)>::type {
	    return op(std::forward<OpArgs>(std::get<Indices>(t))...);
	}

	template <typename Op,
		  typename... OpArgs,
		  template <typename...> class T>
	    static auto apply_tuple(Op&& op, T<OpArgs...> const& t)
	    -> typename std::result_of<Op(OpArgs...)>::type {
	    return op(std::forward<OpArgs const>(std::get<Indices>(t))...);
	}
    };

    template <typename Op,
	      typename... OpArgs,
	      typename Indices = typename make_indices<0, OpArgs...>::type,
	      template <typename...> class T>
    auto apply_tuple(Op&& op, T<OpArgs...>&& t)
	-> typename std::result_of<Op(OpArgs...)>::type {
	return apply_tuple_impl<Indices>::apply_tuple(std::forward<Op>(op), std::forward<T<OpArgs...>>(t));
    }

    template <typename Op,
	      typename... OpArgs,
	      typename Indices = typename make_indices<0, OpArgs...>::type,
	      template <typename...> class T>
    auto apply_tuple(Op&& op, T<OpArgs...> const& t)
	-> typename std::result_of<Op(OpArgs...)>::type {
	return apply_tuple_impl<Indices>::apply_tuple(std::forward<Op>(op), std::forward<T<OpArgs...> const>(t));
    }
}

#endif
